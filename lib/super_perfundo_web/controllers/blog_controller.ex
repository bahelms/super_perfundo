defmodule SuperPerfundoWeb.BlogController do
  use SuperPerfundoWeb, :controller

  def index(conn, _params) do
    posts = SuperPerfundo.Blog.list_posts()
    render(conn, "index.html", posts: posts)
  end
end
