defmodule SuperPerfundo.Email do
  use Bamboo.Phoenix, view: SuperPerfundo.EmailView

  def send_published_emails do
    SuperPerfundo.Blog.Subscribe.subscriptions()
    |> Enum.map(& &1.address)
    |> Enum.map(&published_email/1)
    |> Enum.each(&deliver/1)
  end

  def published_email(recipient) do
    new_email(
      to: recipient,
      from: "SuperPerfundo <tech@superperfundo.tech>",
      subject: "A new article has been published at SuperPerfundo.Tech!"
    )
    |> render(:published_email)
  end

  def deliver(email) do
    SuperPerfundo.Mailer.deliver_now(email)
  end
end
