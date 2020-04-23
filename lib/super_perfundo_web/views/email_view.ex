defmodule SuperPerfundoWeb.EmailView do
  use SuperPerfundoWeb, :view

  defdelegate format_date(post), to: SuperPerfundoWeb.BlogView
end
