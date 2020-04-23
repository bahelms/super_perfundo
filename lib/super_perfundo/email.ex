defmodule SuperPerfundo.Email do
  use Bamboo.Phoenix, view: SuperPerfundoWeb.EmailView

  def send_published_emails(post) do
    SuperPerfundo.Blog.Subscription.list_subscriptions()
    |> Enum.map(& &1.address)
    |> Enum.map(&published_email(&1, post))
    |> Enum.each(&deliver/1)
  end

  def published_email(recipient, post) do
    new_email(
      to: recipient,
      from: "SuperPerfundo <tech@superperfundo.tech>",
      subject: "A new article has been published at SuperPerfundo.Tech!"
    )
    |> render(:published_email, post: post, email: recipient)
  end

  def deliver(email) do
    SuperPerfundo.Mailer.deliver_now(email)
  end
end
