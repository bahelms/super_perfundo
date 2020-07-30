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

    test "the active piece is moved to the position on the board" do
      state = %{winning_state: nil, board: Board.new(), active_piece: 9}
      new_state = Game.position_chosen(0, state)
      assert elem(new_state.board, 0) == 9
      assert new_state.active_piece == nil
      refute new_state.winning_state
    end

    test "winning state in re-evaluated" do
      state = %{winning_state: nil, board: winning_board(), active_piece: 0}
      new_state = Game.position_chosen(0, state)
      assert new_state.winning_state
    end
  end

  defp winning_board do
    Board.new()
    |> Board.set_piece(1, 1)
    |> Board.set_piece(2, 2)
    |> Board.set_piece(3, 3)
  end
end
