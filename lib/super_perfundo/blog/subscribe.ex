defmodule SuperPerfundo.Blog.Subscribe do
  def verify_email(email) do
    if Regex.match?(~r/^[\w.%+-]+@[\w.-]+\.[A-Z]{2,}$/i, email) do
      {:ok, email}
    else
      :error
    end
  end

  def persist(email) do
    # ExAws.S3.put_object("bucket", "name", "contents") |> ExAws.request()
    # ExAws.S3.get_object("bucket", "name") |> ExAws.request()
  end
end
