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

    test "clicking a position that is already taken is a no-op", %{conn: conn} do
      {:ok, view, _html} = live(conn, "/quarto")
      html = view |> element("#game-start-btn") |> render_click()

      # The coin toss is random. If the user won it they have to hand the AI a
      # piece first and take one back; if the AI won it the user already holds
      # one. Both branches end with the user placing a piece on position 0 --
      # or with the AI already sitting there, which is just as good here.
      if html =~ "Select Opponent" do
        view |> element(~s([phx-value-piece="#{first_remaining_piece(html)}"])) |> render_click()
      end

      html = view |> element(~s([phx-value-position="0"])) |> render_click()

      # Re-clicking the occupied slot used to hand the whole assigns map back
      # to assign/2, including the reserved :flash key, and crash the process.
      assert view |> element(~s([phx-value-position="0"])) |> render_click() == html
    end
  end

  describe "end of game" do
    test "a full board with no four in a row renders a draw" do
      html = render_state(board: full_board(), draw: true)

      assert html =~ "Draw!"
      refute html =~ "Winner:"
      refute html =~ "Select Opponent"
      refute html =~ "thinking"
    end

    test "a win still renders the winner" do
      html = render_state(board: full_board(), active_player: :ai, winning_state: [0, 1, 2, 3])

      assert html =~ "Winner: AI!"
      refute html =~ "Draw!"
      refute html =~ "Select Opponent"
    end
  end

  defp render_state(assigns) do
    defaults = [
      board: SuperPerfundo.Quarto.Board.new(),
      active_piece: nil,
      active_player: nil,
      winning_state: nil,
      draw: false,
      game_start: false,
      chosen_player: :user,
      __changed__: nil
    ]

    defaults
    |> Keyword.merge(assigns)
    |> Map.new()
    |> QuartoLive.render()
    |> rendered_to_string()
  end

  defp full_board do
    List.to_tuple([7, 8, 5, 10, 12, 3, 14, 1, 15, 13, 9, 6, 2, 11, 4, 0])
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
