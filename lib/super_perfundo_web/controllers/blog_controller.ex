defmodule SuperPerfundoWeb.BlogController do
  use SuperPerfundoWeb, :controller

  def index(conn, _params) do
    posts = SuperPerfundo.Blog.list_posts()
    render(conn, "index.html", posts: posts)
  end

  def show(conn, %{"id" => id}) do
    post = SuperPerfundo.Blog.get_post(id)
    render(conn, "show.html", post: post)
  end
end
