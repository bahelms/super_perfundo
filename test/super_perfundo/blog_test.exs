defmodule SuperPerfundo.BlogTest do
  use ExUnit.Case
  alias SuperPerfundo.Blog

  test "getting post by ID" do
    p = Blog.get_post("01-01-awesome")
    assert p.title == "Awesome post hey"
  end

  test "filtering posts by tag" do
    posts = Blog.list_posts(for_tag: "monkeys")
    assert length(posts) == 4
  end
end
