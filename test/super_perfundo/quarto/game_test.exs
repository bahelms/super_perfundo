defmodule SuperPerfundo.Quarto.GameTest do
  use ExUnit.Case
  alias SuperPerfundo.Quarto.{Board, Game}

  test "choose_player returns :ai or :user" do
    assert Enum.member?([:ai, :user], Game.choose_player())
  end

  describe "position_chosen/2" do
    test "state does not change if winning state exists" do
      state = %{winning_state: true, board: Board.new()}
      assert state == Game.position_chosen(nil, state)
    end

    test "state does not change if the position already has a piece" do
      board = Board.set_piece(Board.new(), 0, 0)
      state = %{winning_state: true, board: board}
      assert state == Game.position_chosen(0, state)
    end

    test "only game state is handed back, never reserved LiveView assigns" do
      state = %{
        winning_state: true,
        board: Board.new(),
        flash: %{},
        __changed__: %{},
        live_action: nil
      }

      assert Game.position_chosen(0, state) == %{winning_state: true, board: Board.new()}
    end

    test "the active piece is moved to the position on the board" do
      state = %{winning_state: nil, board: Board.new(), active_piece: 9, active_player: :user}
      new_state = Game.position_chosen(0, state)
      assert elem(new_state.board, 0) == 9
      assert new_state.active_piece == nil
      refute new_state.winning_state
      refute new_state.draw
      assert new_state.active_player == :user
    end

    test "winning state in re-evaluated" do
      state = %{winning_state: nil, board: winning_board(), active_piece: 0, active_player: :user}
      new_state = Game.position_chosen(0, state)
      assert new_state.winning_state
      refute new_state.draw
    end

    test "filling the last position with no four in a row is a draw" do
      state = %{
        winning_state: nil,
        board: draw_board(),
        active_piece: 0,
        active_player: :user
      }

      new_state = Game.position_chosen(15, state)
      assert new_state.draw
      refute new_state.winning_state
      assert new_state.active_piece == nil
      assert new_state.active_player == nil
    end

    test "filling the last position with a four in a row is a win, not a draw" do
      # Swapping piece 1 onto the sideline leaves a dark piece for the last
      # slot, which completes the dark diagonal 0-5-10-15.
      state = %{
        winning_state: nil,
        board: Board.set_piece(draw_board(), 0, 7),
        active_piece: 1,
        active_player: :user
      }

      new_state = Game.position_chosen(15, state)
      assert new_state.winning_state
      refute new_state.draw
      assert new_state.active_player == :user
    end
  end

  defp winning_board do
    Board.new()
    |> Board.set_piece(1, 1)
    |> Board.set_piece(2, 2)
    |> Board.set_piece(3, 3)
  end

  # 15 of the 16 pieces laid out so that the board holds no four in a row and
  # the leftover piece (0) does not make one either -- placing it at position
  # 15 fills the board for a draw.
  defp draw_board do
    [7, 8, 5, 10, 12, 3, 14, 1, 15, 13, 9, 6, 2, 11, 4]
    |> Enum.with_index()
    |> Enum.reduce(Board.new(), fn {piece, position}, board ->
      Board.set_piece(board, piece, position)
    end)
  end
end
