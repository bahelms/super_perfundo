defmodule SuperPerfundo.Blog.PublishedPostsTest do
  @moduledoc """
  Smoke coverage for the *real* published articles.

  The rest of the suite runs against the fixtures in `test/posts/`, because
  `config/test.exs` overrides `:posts_pattern`. That leaves the actual articles --
  the ones with the code blocks, raw HTML blocks and markdown edge cases that a
  dependency upgrade will disturb -- completely untested. This module parses every
  real post directly, bypassing the config override.

  Scope note: these assertions check structure, not rendered bytes. They cannot
  see a renderer changing its output while keeping the shape intact --
  `mix snapshot` is what covers that.
  """
  use ExUnit.Case, async: true

  alias SuperPerfundo.Blog.Post

  @published_glob "posts/published/**/*.md"

  defp published_paths, do: Path.wildcard(@published_glob)

  test "the published-post glob actually matches files" do
    # Guards the rest of this module: a glob that silently matches nothing would
    # make every generated test below vacuously pass.
    assert length(published_paths()) > 0,
           "no posts matched #{@published_glob} -- is the working directory wrong?"
  end

  for path <- Path.wildcard(@published_glob) do
    @path path
    @source File.read!(path)

    describe "#{Path.relative_to_cwd(path)}" do
      setup do
        {:ok, post: Post.parse!(@path), source: @source}
      end

      test "parses into a fully populated struct", %{post: post} do
        assert is_binary(post.id) and post.id != ""
        assert is_binary(post.title) and String.trim(post.title) != ""
        assert is_binary(post.description) and String.trim(post.description) != ""
        assert is_binary(post.body) and post.body != ""
      end

      test "id and date agree with the file path", %{post: post} do
        [year, filename] = @path |> Path.split() |> Enum.take(-2)
        [month_day, slug] = filename |> Path.rootname() |> String.split("_", parts: 2)
        [month, day] = month_day |> String.split("-") |> Enum.map(&String.to_integer/1)

        assert post.id == slug
        assert post.date.year == String.to_integer(year)
        assert post.date.month == month
        assert post.date.day == day
      end

      test "has at least one non-empty tag", %{post: post} do
        assert is_list(post.tags) and post.tags != []
        assert Enum.all?(post.tags, &(is_binary(&1) and String.trim(&1) != ""))
        assert post.tags == Enum.sort(post.tags)
      end

      test "renders fenced code blocks as highlighted markup", %{post: post, source: source} do
        if String.contains?(source, "```") do
          assert post.body =~ "<pre><code",
                 "source has fenced code but the rendered body has no <pre><code> block"
        end
      end

      test "body is rendered HTML with no leaked field delimiters", %{post: post} do
        assert String.contains?(post.body, "<"), "body contains no HTML at all"

        # A parsing failure would leave the ==field== markers in the output.
        refute post.body =~ ~r/^==\w+==$/m, "found an unparsed ==field== delimiter"
      end
    end
  end
end
