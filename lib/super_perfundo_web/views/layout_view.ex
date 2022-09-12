defmodule SuperPerfundoWeb.LayoutView do
  use SuperPerfundoWeb, :view

  def og_description(%{post: post}), do: post.description
  def og_description(_), do: ""

  def og_title(%{post: post}), do: post.title
  def og_title(_), do: ""

  def og_image(%{post: post, conn: conn}), do: Routes.static_url(conn, "/images/#{post.image}")
  def og_image(_), do: ""

  def post_id(%{post: post}), do: post.id
  def post_id(_), do: ""

  def analytics_src, do: Application.get_env(:super_perfundo, :analytics_src)
end
