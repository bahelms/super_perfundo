defmodule SuperPerfundo.Blog.Subscribe do
  @timezone "US/Eastern"

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
    |> hydrate()
    |> add_email(email)
    |> serialize()
    |> storage.store_emails()
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
    [%Email{address: address, timestamp: Timex.now(@timezone)} | emails]
  end

  defp serialize(emails) do
    emails
    |> Enum.map(fn %{address: address, timestamp: timestamp} ->
      "#{address},#{timestamp}"
    end)
    |> Enum.join("\n")
  end
end
