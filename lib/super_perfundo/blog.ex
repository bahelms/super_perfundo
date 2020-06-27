defmodule SuperPerfundo.Blog do
  alias SuperPerfundo.Blog.Post

  for app <- [:earmark, :makeup_elixir, :timex], do: Application.ensure_all_started(app)

  published_posts =
    Application.compile_env(:super_perfundo, :posts_pattern)
    |> Path.wildcard()

  posts =
    for path <- published_posts do
      @external_resource Path.relative_to_cwd(path)
      Post.parse!(path)
    end

  @posts Enum.sort_by(posts, & &1.date, {:desc, Date})

  draft_posts =
    Application.compile_env(:super_perfundo, :drafts_pattern)
    |> Path.wildcard()

  drafts =
    for path <- draft_posts do
      @external_resource Path.relative_to_cwd(path)
      Post.parse!(path)
    end

  @drafts Enum.sort_by(drafts, & &1.date, {:desc, Date})

  def list_posts, do: @posts

  def list_posts(for_tag: tag) do
    for post <- @posts, tag in post.tags, do: post
  end

  def get_post(id), do: get_article(@posts, id)

  def get_draft(id), do: get_article(@drafts, id)

  defp get_article(articles, id) do
    article = Enum.find(articles, &(&1.id == id))
    struct(article, body: set_image_src(article.body))
  end

  defp set_image_src(text) do
    text
    |> EEx.eval_string(img_url: &"#{SuperPerfundoWeb.Endpoint.url()}/images/#{&1}")
  end
end
