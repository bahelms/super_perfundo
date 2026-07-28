defmodule SuperPerfundo.BlogTest do
  use ExUnit.Case
  alias SuperPerfundo.Blog

  describe "getting a post by ID" do
    test "returns the post" do
      p = Blog.get_post("test")
      assert p.title == "Test post!"
    end

    test "renders a relative image url" do
      p = Blog.get_post("test")
      assert p.body =~ "src=\"/images/test.jpeg\""
    end
  end

  test "filtering posts by tag" do
    posts = Blog.list_posts(for_tag: "donuts")
    assert length(posts) == 2
  end

  describe "getting a draft by ID" do
    test "returns the draft" do
      d = Blog.get_draft("test-draft")
      assert d.title == "Test Draft!"
    end

    test "renders a relative image url" do
      d = Blog.get_draft("test-draft")
      assert d.body =~ "src=\"/images/test.jpeg\""
    end
  end
end
