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

  defmodule TestStorage do
    def get_emails, do: ""

    def store_emails(emails), do: emails
  end

  describe "store_email/1" do
    test "email is added to empty list of emails" do
      emails = Subscribe.store_email("bob@monkey.io", TestStorage)
      assert emails == "bob@monkey.io"
    end

    test "email is added to populated list of emails" do
      emails = Subscribe.store_email("bob@monkey.io", TestStorage)
      assert emails == "bob@monkey.io"
    end
  end
end
