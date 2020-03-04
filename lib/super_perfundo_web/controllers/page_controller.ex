defmodule SuperPerfundoWeb.PageController do
  use SuperPerfundoWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
