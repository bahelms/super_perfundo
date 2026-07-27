defmodule SuperPerfundoWeb.QuartoLiveTest do
  use SuperPerfundoWeb.ConnCase
  import Phoenix.LiveViewTest
  alias SuperPerfundoWeb.QuartoLive

  describe "mount and render" do
    test "renders the board with all 16 slots and the coin-toss modal", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/quarto")

      assert html =~ "game-start-modal"
      assert html =~ "Game on!"

      for position <- 0..15 do
        assert html =~ ~s(phx-value-position="#{position}"),
               "board slot #{position} is missing"
      end

      # The coin toss is random, so accept either outcome.
      assert html =~ "won the coin toss"
    end

    test "renders the 16 remaining pieces", %{conn: conn} do
      {:ok, _view, html} = live(conn, "/quarto")

      for piece <- 0..15 do
        assert html =~ ~s(phx-value-piece="#{piece}"), "remaining piece #{piece} is missing"
      end
    end
  end

  describe "events" do
    test "starting the game dismisses the modal", %{conn: conn} do
      {:ok, view, html} = live(conn, "/quarto")
      assert html =~ "game-start-modal"

      html = view |> element("#game-start-btn") |> render_click()

      refute html =~ "game-start-modal"
    end

    test "choosing the opponent's piece drives an AI turn through the NIF", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/quarto")
      html = view |> element("#game-start-btn") |> render_click()

      # The coin toss is random. If the AI won it, it has already picked a piece
      # for the user, and "piece_chosen" is a no-op until that one is placed --
      # so place it first. Both branches then converge on the user choosing the
      # opponent's piece, which is the only path that runs the Rust MCTS NIF.
      html =
        if html =~ "Select Opponent" do
          html
        else
          view |> element(~s([phx-value-position="0"])) |> render_click()
        end

      assert html =~ "Select Opponent"

      # Pick whatever is actually still available rather than a fixed piece: in
      # the branch above, the piece the AI chose has just been placed on the
      # board and is no longer in the pool, and which piece that is, is random.
      piece = first_remaining_piece(html)

      html = view |> element(~s([phx-value-piece="#{piece}"])) |> render_click()

      # The AI placed the chosen piece, so it has left the remaining pool.
      refute html =~ ~s(phx-value-piece="#{piece}"), "the AI did not place the chosen piece"
      assert html =~ ~s(<div class="piece">), "no piece was rendered after the turn"
    end
  end

  defp first_remaining_piece(html) do
    [_, piece] = Regex.run(~r/phx-value-piece="(\d+)"/, html)
    piece
  end

  test "highlight_for_win returns nil when position is not present" do
    assert QuartoLive.highlight_for_win([1, 2, 3, 4], 8) == nil
  end

  test "highlight_for_win returns CSS class name when position is present" do
    assert QuartoLive.highlight_for_win([1, 2, 3, 4], 3) == "slot-win"
  end

  test "highlight_for_win returns nil when win state is nil" do
    assert QuartoLive.highlight_for_win(nil, 3) == nil
  end
end
