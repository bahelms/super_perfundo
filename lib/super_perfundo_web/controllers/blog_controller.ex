defmodule SuperPerfundoWeb.BlogController do
  use SuperPerfundoWeb, :controller
  alias SuperPerfundo.Blog.Subscribe

  def index(conn, %{"tag" => tag}) do
    posts = SuperPerfundo.Blog.list_posts(for_tag: tag)
    render(conn, "index.html", posts: posts, tag: tag)
  end

  def index(conn, _) do
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

  def about(conn, _) do
    render(conn, "about.html")
  end

  def subscribe(conn, %{"email_address" => email}) do
    case Subscribe.verify_email(email) do
      {:ok, email} ->
        Subscribe.persist(email)
        render(conn, "subscribed.html", email: email)

      :error ->
        conn
        |> put_flash(:error, "Invalid email address. Try again.")
        |> redirect(to: "/")
    end
  end
end
