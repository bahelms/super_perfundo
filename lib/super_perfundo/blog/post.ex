defmodule SuperPerfundo.Blog.Post do
  @enforce_keys [:id, :title, :body, :tags, :description, :date]
  defstruct [:id, :title, :body, :tags, :description, :date]

  @field_pattern ~r/^==(\w+)==\n/m
  @timezone Application.get_env(:super_perfundo, :timezone)

  def parse!(filename) do
    id = parse_id(filename)
    date = parse_date(filename)
    contents = parse_contents(File.read!(filename))
    struct!(__MODULE__, [id: id, date: date] ++ contents)
  end

  defp parse_id(filename) do
    filename
    |> Path.split()
    |> Enum.take(-1)
    |> List.first()
    |> String.split("_")
    |> List.last()
    |> Path.rootname()
  end

  defp parse_date(filename) do
    {year, postname} =
      filename
      |> Path.split()
      |> Enum.take(-2)
      |> case do
        ["drafts", postname] -> {current_date().year, postname}
        [year, postname] -> {String.to_integer(year), postname}
      end

    [month, day] = parse_month_and_day(postname)

    {{year, month, day}, {5, 0, 0}}
    |> Timex.Timezone.convert(@timezone)
  end

  defp parse_month_and_day(postname) do
    postname
    |> String.split("_")
    |> case do
      data when length(data) == 2 ->
        List.first(data)

      _ ->
        date = current_date()
        "#{date.month}-#{date.day}"
    end
    |> String.split("-")
    |> Enum.map(&String.to_integer/1)
  end

  defp current_date, do: Timex.now(@timezone)

  defp parse_contents(contents) do
    parts = Regex.split(@field_pattern, contents, include_captures: true, trim: true)

    for [attr_with_equals, value] <- Enum.chunk_every(parts, 2) do
      [_, attr, _] = String.split(attr_with_equals, "==")
      attr = String.to_atom(attr)
      {attr, parse_attr(attr, value)}
    end
  end

  defp parse_attr(:title, value), do: String.trim(value)
  defp parse_attr(:description, value), do: String.trim(value)

  defp parse_attr(:body, value),
    do:
      Earmark.as_html!(value, %Earmark.Options{code_class_prefix: "language-"})
      # for pre-Prism posts
      |> ExDoc.Highlighter.highlight_code_blocks()

  defp parse_attr(:tags, value),
    do: String.split(value, ",") |> Enum.map(&String.trim/1) |> Enum.sort()
end
