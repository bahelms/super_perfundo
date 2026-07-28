defmodule SuperPerfundo.Blog.Post do
  @enforce_keys [:id, :title, :body, :tags, :description, :date]
  defstruct [:id, :title, :body, :tags, :description, :date, :image]

  @field_pattern ~r/^==(\w+)==\n/m
  @timezone Application.compile_env(:super_perfundo, :timezone)

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
  defp parse_attr(:image, value), do: String.trim(value)

  # Labelled fences get a `language-*` class and are highlighted client-side by
  # Prism. Unlabelled blocks are left as plain <pre><code> on purpose: they hold
  # ASCII diagrams, shell snippets and indented prose, not Elixir.
  #
  # `unsafe: true` lets the raw <div>/<img> blocks in post bodies through --
  # without it comrak strips them. Post bodies are authored in this repo, so
  # there is no untrusted markdown to sanitize.
  #
  # `smart: true` keeps the curly quotes, apostrophes and em dashes that Earmark
  # applied by default; without it every "don't" in ten years of posts reverts
  # to a straight apostrophe.
  defp parse_attr(:body, value) do
    value
    |> MDEx.to_html!(parse: [smart: true], render: [unsafe: true])
    |> external_links_in_new_tab()
  end

  defp parse_attr(:tags, value),
    do: String.split(value, ",") |> Enum.map(&String.trim/1) |> Enum.sort()

  # Stands in for the per-link `{:target="x"}` IALs the posts carried under
  # Earmark, which MDEx has no equivalent for. Only absolute links match:
  # footnote anchors carry no href and internal links are `href="#..."`.
  defp external_links_in_new_tab(html),
    do: Regex.replace(~r/<a href="(https?:)/, html, ~S(<a target="x" href="\1))
end
