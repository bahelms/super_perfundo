defmodule SuperPerfundo.Blog do
  alias SuperPerfundo.Blog.Post

  for app <- [:earmark, :timex], do: Application.ensure_all_started(app)

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

  def list_drafts, do: @drafts

  def get_post(id), do: get_article(@posts, id)

  def get_draft(id), do: get_article(@drafts, id)

  defp get_article(articles, id) do
    article = Enum.find(articles, &(&1.id == id))
    struct(article, body: set_image_src(article.body))
  end

  # Relative on purpose. Post bodies are only ever rendered into web pages, where
  # the browser already has the right origin -- emails use only the title and
  # description, and og:image goes through Routes.static_url/2. Hardcoding a
  # scheme and port here pointed dev images at the https port and its self-signed
  # cert; in prod, force_ssl means a relative path resolves to https anyway.
  defp set_image_src(text) do
    text
    |> EEx.eval_string(img_url: &"/images/#{&1}")
  end
end
