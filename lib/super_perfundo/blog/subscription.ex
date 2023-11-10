defmodule SuperPerfundo.Blog.Subscription do
  @timezone Application.compile_env(:super_perfundo, :timezone)

  defmodule Email do
    defstruct [:address, :timestamp]
  end

  def verify_email(email) do
    if Regex.match?(~r/^[\w.%+-]+@[\w.-]+\.[A-Z]{2,}$/i, email) do
      {:ok, email}
    else
      :error
    end
  end

  def list_subscriptions do
    SuperPerfundo.EmailStorage.get_emails()
    |> hydrate()
  end

  def subscribe(email), do: update(email, :subscribe_email)

  def unsubscribe(email), do: update(email, :unsubscribe_email)

  def subscribe_email(email, storage) do
    storage.get_emails()
    |> hydrate()
    |> add_email(email)
    |> serialize()
    |> storage.store_emails()
  end

  def unsubscribe_email(email, storage) do
    storage.get_emails()
    |> hydrate()
    |> delete_email(email)
    |> serialize()
    |> storage.store_emails()
  end

  defp update(email, action) do
    Task.Supervisor.start_child(
      SuperPerfundo.EmailStorageSupervisor,
      __MODULE__,
      action,
      [email, SuperPerfundo.EmailStorage]
    )
  end

  defp hydrate(""), do: []

  defp hydrate(emails) do
    emails
    |> String.split("\n")
    |> Enum.map(&to_struct/1)
  end

  defp to_struct(record) do
    [address | [timestamp]] = String.split(record, ",")
    %Email{address: address, timestamp: timestamp}
  end

  defp add_email(emails, address) do
    emails
    |> Enum.find(&(&1.address == address))
    |> case do
      nil -> [%Email{address: address, timestamp: Timex.now(@timezone)} | emails]
      _ -> nil
    end
  end

  defp delete_email(emails, address) do
    emails
    |> Enum.find(&(&1.address == address))
    |> case do
      nil -> emails
      email -> List.delete(emails, email)
    end
  end

  defp serialize(nil), do: nil

  defp serialize(emails) do
    emails
    |> Enum.map(fn %{address: address, timestamp: timestamp} ->
      "#{address},#{timestamp}"
    end)
    |> Enum.join("\n")
  end
end
