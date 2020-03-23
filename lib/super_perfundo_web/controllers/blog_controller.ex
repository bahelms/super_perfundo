defmodule SuperPerfundoWeb.BlogController do
  use SuperPerfundoWeb, :controller

  def index(conn, %{"tag" => tag}) do
    posts = SuperPerfundo.Blog.list_posts(for_tag: tag)
    render(conn, "index.html", posts: posts, tag: tag)
  end

  def index(conn, _params) do
    posts = SuperPerfundo.Blog.list_posts()
    render(conn, "index.html", posts: posts, tag: nil)
  end

  def show(conn, %{"id" => id}) do
    post = SuperPerfundo.Blog.get_post(id)
    render(conn, "show.html", post: post)
  end

  def show_draft(conn, %{"id" => id}) do
    render(conn, "show.html", post: SuperPerfundo.Blog.get_draft(id))
  end
end
