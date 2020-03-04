defmodule SuperPerfundo.Blog.Post do
  @enforce_keys [:id, :title, :body, :tags, :date]
  defstruct [:id, :title, :body, :tags, :date]

  @field_pattern ~r/^==(\w+)==\n/m

  def parse!(filename) do
    {id, date} = parse_id_and_date(filename)
    contents = parse_contents(File.read!(filename))
    struct!(__MODULE__, [id: id, date: date] ++ contents)
  end

  defp parse_id_and_date(filename) do
    [year, month_day_id] =
      filename
      |> Path.split()
      |> Enum.take(-2)

    [month, day, id_with_ext] = String.split(month_day_id, "-", parts: 3)
    {Path.rootname(id_with_ext), Date.from_iso8601!("#{year}-#{month}-#{day}")}
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
  defp parse_attr(:body, value), do: value

  defp parse_attr(:tags, value),
    do: String.split(value, ",") |> Enum.map(&String.trim/1) |> Enum.sort()
end
