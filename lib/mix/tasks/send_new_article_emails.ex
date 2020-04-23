defmodule Mix.Tasks.SendNewArticleEmails do
  @moduledoc """
  This task sends emails to all subscriptions, notifying them that a new article
  has been published.
  """
  @shortdoc "Sends new article email notifications"

  use Mix.Task

  @impl Mix.Task
  def run(args) do
    # Determine newly published article
    # SuperPerfundo.Blog.list_posts()

    # SuperPerfundo.Email.send_published_emails(new_post)
    IO.inspect(args, label: "publish args")
  end
end
