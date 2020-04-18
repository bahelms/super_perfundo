defmodule SuperPerfundo.Email do
  import Bamboo.Email

  def notification_email do
    new_email(
      to: "jimbonk69@gmail.com",
      from: "tech@superperfundo.tech",
      subject: "Test notification",
      html_body: "<h1>hey there</h1>",
      text_body: "hey there"
    )
  end
end
