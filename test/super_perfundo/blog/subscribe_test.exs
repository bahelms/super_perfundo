defmodule SuperPerfundo.Blog.SubscribeTest do
  use ExUnit.Case
  alias SuperPerfundo.Blog.Subscribe

  describe "verify_email/1" do
    test "returns :ok when given valid email address" do
      assert {:ok, _} = Subscribe.verify_email("bob@awesome.io")
    end

    test "return :error when given an invalid email address" do
      assert :error = Subscribe.verify_email("bob")
      assert :error = Subscribe.verify_email("bob@")
      assert :error = Subscribe.verify_email("bob@gmail")
      assert :error = Subscribe.verify_email("@gmail.com")
      assert :error = Subscribe.verify_email("bob@gmail.")
    end
  end

  describe "persist/1" do
    test "email is stored in AWS S3" do
    end
  end
end
