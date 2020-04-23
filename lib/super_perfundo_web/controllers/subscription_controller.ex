defmodule SuperPerfundoWeb.SubscriptionController do
  use SuperPerfundoWeb, :controller
  alias SuperPerfundo.Blog.Subscription

  def create(conn, %{"email_address" => email}) do
    case Subscription.verify_email(email) do
      {:ok, email} ->
        Subscription.subscribe(email)
        render(conn, "subscribed.html", email: email)

      :error ->
        conn
        |> put_flash(:error, "Invalid email address. Try again.")
        |> redirect(to: "/")
    end
  end

  def edit(conn, %{"email" => email}) do
    render(conn, "edit.html", email: email)
  end

  def destroy(conn, %{"email" => email}) do
    Subscription.unsubscribe(email)
    render(conn, "unsubscribed.html", email: email)
  end
end
