defmodule SuperPerfundo.Blog.Subscribe do
  def verify_email(email) do
    if Regex.match?(~r/^[\w.%+-]+@[\w.-]+\.[A-Z]{2,}$/i, email) do
      {:ok, email}
    else
      :error
    end
  end

  def persist(email) do
    Task.Supervisor.start_child(
      SuperPerfundo.EmailStorageSupervisor,
      __MODULE__,
      :store_email,
      [email, SuperPerfundo.EmailStorage]
    )
  end

  def store_email(email, storage) do
    storage.get_emails()
    |> to_list()
    |> add_email(email)
    |> serialize()
    |> storage.store_emails()
  end

  defp to_list(""), do: []
  defp to_list(emails), do: String.split(emails, "\n")

  defp serialize(emails) do
    Enum.join(emails, "\n")
  end

  defp add_email(emails, email) do
    [email | emails]
  end
end
