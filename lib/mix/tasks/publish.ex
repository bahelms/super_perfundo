defmodule Mix.Tasks.Publish do
  @moduledoc """
  This task publishes a draft article.
  """
  @shortdoc "Publishes a draft article"

  use Mix.Task

  @impl Mix.Task
  def run(args) do
    # SuperPerfundo.Blog.list_posts()
    # Find newly published article

    IO.inspect(args, label: "publish args")
  end
end
