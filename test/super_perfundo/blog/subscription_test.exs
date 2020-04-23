defmodule SuperPerfundo.Blog.SubscriptionTest do
  use ExUnit.Case
  alias SuperPerfundo.Blog.Subscription

  describe "verify_email/1" do
    test "returns :ok when given valid email address" do
      assert {:ok, _} = Subscription.verify_email("bob@awesome.io")
    end

    test "return :error when given an invalid email address" do
      assert :error = Subscription.verify_email("bob")
      assert :error = Subscription.verify_email("bob@")
      assert :error = Subscription.verify_email("bob@gmail")
      assert :error = Subscription.verify_email("@gmail.com")
      assert :error = Subscription.verify_email("bob@gmail.")
    end
  end

  defmodule EmptyStorage do
    def get_emails, do: ""
    def store_emails(emails), do: emails
  end

  defmodule PopulatedStorage do
    def get_emails, do: "karl@io.com,some-timestamp\njim@day.spa,time"
    def store_emails(emails), do: emails
  end

  describe "subscribe_email/1" do
    test "email is added to empty list of emails with timestamp" do
      [email | [time]] =
        Subscription.subscribe_email("bob@monkey.io", EmptyStorage)
        |> String.split(",")

      assert email == "bob@monkey.io"
      assert time =~ ~r/\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}.+US\/Eastern/
    end

    test "email is added to populated list of emails with timestamp" do
      emails =
        Subscription.subscribe_email("bob@monkey.io", PopulatedStorage)
        |> String.split("\n")
        |> Enum.map(fn email ->
          [email | [time]] = String.split(email, ",")
          {email, time}
        end)

      assert length(emails) == 3

      {addr, time} =
        Enum.find(emails, fn {address, _} ->
          address == "bob@monkey.io"
        end)

      assert addr == "bob@monkey.io"
      assert time =~ ~r/\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}.+US\/Eastern/
    end

    test "duplicate emails are not added" do
      refute Subscription.subscribe_email("karl@io.com", PopulatedStorage)
    end
  end

  describe "unsubscribe_email/1" do
    test "email is removed from stored emails" do
      emails = Subscription.unsubscribe_email("jim@day.spa", PopulatedStorage)
      assert emails == "karl@io.com,some-timestamp"
    end

    test "no-op if email is not found" do
      emails = Subscription.unsubscribe_email("not@found.com", PopulatedStorage)
      assert emails == "karl@io.com,some-timestamp\njim@day.spa,time"
    end

    test "no-op if there are no stored emails" do
      assert Subscription.unsubscribe_email("not@found.com", EmptyStorage) == ""
    end
  end
end
