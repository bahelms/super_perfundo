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

  defmodule EmptyStorage do
    def get_emails, do: ""
    def store_emails(emails), do: emails
  end

  defmodule PopulatedStorage do
    def get_emails, do: "karl@io.com,some-timestamp\njim@day.spa,time"
    def store_emails(emails), do: emails
  end

  describe "store_email/1" do
    test "email is added to empty list of emails with timestamp" do
      [email | [time]] =
        Subscribe.store_email("bob@monkey.io", EmptyStorage)
        |> String.split(",")

      assert email == "bob@monkey.io"
      assert time =~ ~r/\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2}.+US\/Eastern/
    end

    test "email is added to populated list of emails with timestamp" do
      emails =
        Subscribe.store_email("bob@monkey.io", PopulatedStorage)
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
      refute Subscribe.store_email("karl@io.com", PopulatedStorage)
    end
  end
end
