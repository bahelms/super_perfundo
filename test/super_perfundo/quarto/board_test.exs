defmodule SuperPerfundo.Quarto.BoardTest do
  use ExUnit.Case
  alias SuperPerfundo.Quarto.Board

  setup do
    {:ok, board: Board.new()}
  end

  test "new/0 returns a 16 element tuple", %{board: board} do
    assert tuple_size(board) == 16
  end

  test "set_piece updates board with new piece integer", %{board: board} do
    new_board = Board.set_piece(board, 14, 2)
    assert elem(new_board, 2) == 14
  end

  describe "piece_at_position/2" do
    test "converts integer at position to Piece", %{board: board} do
      piece =
        board
        |> put_elem(1, 0)
        |> Board.piece_at_position(1)

      assert piece.shape == "cube"
      assert piece.size == "short"
      assert piece.fill == "solid"
      assert piece.color == "light"
    end

    test "empty position returns nil", %{board: board} do
      assert Board.piece_at_position(board, 0) == nil
    end
  end

  describe "integer_to_piece/1" do
    test "converts integer to Piece" do
      piece = Board.integer_to_piece(15)
      assert piece.shape == "cylinder"
      assert piece.size == "tall"
      assert piece.fill == "hollow"
      assert piece.color == "dark"
    end

    test "handles nil" do
      assert Board.integer_to_piece(nil) == nil
    end
  end

  describe "remaining_pieces/1" do
    test "returns the pieces not in the board" do
      remaining =
        {nil, 1, 2, 3, 4, 5, nil, 6, 7, nil, nil, nil, nil, nil, nil, nil}
        |> Board.remaining_pieces()

      assert remaining == MapSet.new([8, 9, 10, 11, 12, 13, 14, 15])
    end
  end
end
