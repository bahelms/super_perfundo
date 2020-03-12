defmodule SuperPerfundo.Blog do
  alias SuperPerfundo.Blog.Post

  for app <- [:earmark, :makeup_elixir], do: Application.ensure_all_started(app)

  paths =
    Application.compile_env(:super_perfundo, :posts_pattern)
    |> Path.wildcard()

  posts =
    for path <- paths do
      @external_resource Path.relative_to_cwd(path)
      Post.parse!(path)
    end

  @posts Enum.sort_by(posts, & &1.date, {:desc, Date})

  def list_posts, do: @posts

  def list_posts(for_tag: tag) do
    for post <- @posts, tag in post.tags, do: post
  end

  def get_post(id), do: Enum.find(@posts, &(&1.id == id))
end
