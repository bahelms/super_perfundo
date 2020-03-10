defmodule SuperPerfundoWeb.BlogView do
  use SuperPerfundoWeb, :view

  def tags(post) do
    post.tags
    |> Enum.join(", ")
  end

  def format_date(post) do
    {post.date.year, post.date.month, post.date.day}
    |> Timex.format!("{Mfull} {D}, {YYYY}")
  end
end
