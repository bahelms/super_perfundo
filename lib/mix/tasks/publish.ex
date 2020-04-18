defmodule Mix.Tasks.Publish do
  @moduledoc """
  This task publishes a draft article.
  """
  @shortdoc "Publishes a draft article"

  use Mix.Task

  @impl Mix.Task
  def run(args) do
    IO.inspect(args, label: "publish args")
  end
end
