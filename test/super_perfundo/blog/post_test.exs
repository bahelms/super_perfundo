defmodule SuperPerfundo.Blog.PostTest do
  use ExUnit.Case
  alias SuperPerfundo.Blog.Post

  describe "parse!/1" do
    test "id is parsed from filename" do
      post = Post.parse!("test/posts/published/2020/6-23_post-id.md")
      assert post.id == "post-id"
    end

    test "date is parsed from directories and filename" do
      post = Post.parse!("test/posts/published/2020/6-23_post-id.md")
      assert "#{post.date}" =~ "2020-06-23"
    end
  end
end
