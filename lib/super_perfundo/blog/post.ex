defmodule SuperPerfundo.Blog.Post do
  @enforce_keys [:id, :title, :body, :tags, :description, :date]
  defstruct [:id, :title, :body, :tags, :description, :date]

  @field_pattern ~r/^==(\w+)==\n/m

  def parse!(filename) do
    id = parse_id(filename)
    date = parse_date(filename)
    contents = parse_contents(File.read!(filename))
    struct!(__MODULE__, [id: id, date: date] ++ contents)
  end

  defp parse_id(filename) do
    filename
    |> Path.split()
    |> List.last()
    |> Path.rootname()
  end

  defp parse_date(filename) do
    {date, _} = File.stat!(filename, time: :local).mtime
    Date.from_erl!(date)
  end

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
    do: Earmark.as_html!(value) |> ExDoc.Highlighter.highlight_code_blocks()

  defp parse_attr(:tags, value),
    do: String.split(value, ",") |> Enum.map(&String.trim/1) |> Enum.sort()
end
