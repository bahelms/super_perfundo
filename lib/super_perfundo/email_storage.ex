defmodule SuperPerfundo.EmailStorage do
  @object_name Application.compile_env(:super_perfundo, :email_list)
  @bucket "super-perfundo"

  @doc """
  get_object
    success:
      {:ok, %{body: "...."}}
    error:
      {:error, {:http_error, status, %{...}}}
  """
  @spec get_emails() :: String.t()
  def get_emails do
    response =
      ExAws.S3.get_object(@bucket, @object_name)
      |> ExAws.request()

    case response do
      {:ok, %{body: emails}} ->
        emails

      {:error, error} ->
        IO.inspect(error, label: "S3 get_object error")
        ""
    end
  end

  @doc """
  put_object
    success:
      {:ok, %{body: "...."}}
  """
  @spec store_emails(nil) :: nil
  def store_emails(nil), do: nil

  @spec store_emails(String.t()) :: any
  def store_emails(emails) do
    ExAws.S3.put_object(@bucket, @object_name, emails)
    |> ExAws.request()
  end
end
