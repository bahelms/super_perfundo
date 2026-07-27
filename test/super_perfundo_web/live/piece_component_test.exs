defmodule SuperPerfundoWeb.PieceComponentTest do
  use SuperPerfundoWeb.ConnCase
  import Phoenix.LiveViewTest
  alias SuperPerfundoWeb.PieceComponent

  # Whitespace between tags carries no meaning here and HEEx indents differently
  # from the old LEEx templates, so compare on structure rather than formatting.
  defp squish(html) do
    html |> to_string() |> String.replace(~r/\s+/, " ") |> String.trim()
  end

  test "nil returns empty string" do
    assert render_component(&PieceComponent.piece/1, board: {nil}, position: 0) == ""
  end

  test "HTML for a tall, dark, solid cube" do
    # 5 = 0101 -> cube, tall, solid, dark
    html = squish(render_component(&PieceComponent.piece/1, board: {5}, position: 0))

    assert html =~ ~s(<div class="piece">)
    assert html =~ ~s(<div class="cube">)

    for side <- ~w(front back top bottom left right) do
      assert html =~ ~s(<div class="side #{side} tall dark"></div>)
    end

    refute html =~ "hollow"
    refute html =~ "cylinder"
  end

  test "HTML for a short, light, hollow cylinder" do
    # 10 = 1010 -> cylinder, short, hollow, light
    html = squish(render_component(&PieceComponent.piece/1, piece: 10))

    assert html =~ ~s(<div class="cylinder short">)
    assert html =~ ~s(<div class="bottom short light"></div>)
    assert html =~ ~s(<div class="middle short light"></div>)
    assert html =~ ~s(<div class="top light"></div>)
    assert html =~ ~s(<div class="hollow"></div>)
    refute html =~ "cube"
  end

  test "renders from a raw piece integer as well as from a board position" do
    from_board = squish(render_component(&PieceComponent.piece/1, board: {5}, position: 0))
    from_int = squish(render_component(&PieceComponent.piece/1, piece: 5))

    assert from_board == from_int
  end
end
