defmodule SuperPerfundoWeb.BlogView do
  use SuperPerfundoWeb, :view

  def tag_links(tags) do
    tags
    |> Enum.map(fn tag ->
      link(tag, to: "/?tag=#{tag}")
      |> safe_to_string()
    end)
    |> Enum.join(", ")
    |> raw()
  end

  def format_date(post) do
    {post.date.year, post.date.month, post.date.day}
    |> Timex.format!("{Mfull} {D}, {YYYY}")
  end

  def index_heading(nil), do: "All Articles"
  def index_heading(tag), do: "All Articles tagged with \"#{tag}\""
end
