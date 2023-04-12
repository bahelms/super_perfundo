defmodule Mix.Tasks.Draft do
  @moduledoc """
  Creates a new draft article with given name.
  The filename has the format DAY-MONTH_NAME.md and is stored in `posts/drafts/`.
  """

  use Mix.Task

  @shortdoc "Creates a new draft article with given name"
  def run(name) do
    today = Date.utc_today()
    filename = "#{today.month}-#{today.day}_#{name}.md"
    template = File.read!("test/posts/drafts/test-draft.md")
    File.write!("#{File.cwd!()}/posts/drafts/#{filename}", template)
  end
end
