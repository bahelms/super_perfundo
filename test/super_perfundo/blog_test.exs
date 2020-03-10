defmodule SuperPerfundo.BlogTest do
  use ExUnit.Case
  alias SuperPerfundo.Blog

  test "get_post finds the blog post by ID" do
    p = Blog.get_post("awesome")
    assert p.title == "Awesome post"
  end
end
