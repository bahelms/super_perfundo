defmodule SuperPerfundo.BlogTest do
  use ExUnit.Case
  alias SuperPerfundo.Blog

  test "getting post by ID" do
    p = Blog.get_post("test")
    assert p.title == "Test post!"
  end

  test "filtering posts by tag" do
    posts = Blog.list_posts(for_tag: "donuts")
    assert length(posts) == 2
  end
end
