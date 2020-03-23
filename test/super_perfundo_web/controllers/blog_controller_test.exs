defmodule SuperPerfundoWeb.BlogControllerTest do
  use SuperPerfundoWeb.ConnCase

  test "show_draft", %{conn: conn} do
    response =
      conn
      |> get(Routes.blog_path(conn, :show_draft, "test_draft"))
      |> html_response(200)

    assert response =~ "Test Draft!"
  end
end
