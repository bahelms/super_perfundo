defmodule SuperPerfundo.Blog do
  alias SuperPerfundo.Blog.Post

  post_paths = Path.wildcard("posts/**/*.md") |> Enum.sort()

  posts =
    for path <- post_paths do
      @external_resource Path.relative_to_cwd(path)
      Post.parse!(path)
    end

  @posts Enum.sort_by(posts, & &1.date, {:desc, Date})

  def list_posts do
    @posts
  end
end
