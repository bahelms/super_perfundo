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
    test "returns the pieces not in the board or active piece" do
      remaining =
        {nil, 1, 2, 3, 4, 5, nil, 6, 7, nil, nil, 0, nil, nil, nil, nil}
        |> Board.remaining_pieces(13)

      assert remaining == MapSet.new([8, 9, 10, 11, 12, 14, 15])
    end
  end

  describe "four_in_a_row?/1" do
    test "returns false when no four pieces match", %{board: board} do
      refute Board.four_in_a_row?(board)
      refute Board.four_in_a_row?({1, 2, 4, 8, 12, 5, nil, 6, 7, nil, nil, 0, nil, nil, nil, nil})
    end

    test "finds match on four light pieces" do
      assert Board.four_in_a_row?({0, 2, 4, 8})
    end

    test "finds match on four dark pieces" do
      assert Board.four_in_a_row?({1, 3, 5, 9})
    end

    test "finds match on four solid pieces" do
      assert Board.four_in_a_row?({0, 1, 4, 8})
    end

    test "finds match on four hollow pieces" do
      assert Board.four_in_a_row?({2, 3, 6, 10})
    end

    test "finds match on four short pieces" do
      assert Board.four_in_a_row?({0, 1, 2, 8})
    end

    test "finds match on four tall pieces" do
      assert Board.four_in_a_row?({4, 5, 6, 12})
    end

    test "finds match on four cube pieces" do
      assert Board.four_in_a_row?({0, 1, 2, 4})
      assert Board.four_in_a_row?({3, 4, 6, 7})
    end

    test "finds match on four cylinder pieces" do
      assert Board.four_in_a_row?({8, 9, 10, 12})
    end

    test "handles false positives" do
      refute Board.four_in_a_row?(
               {15, 10, 9, 4, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil}
             )
    end

    test "checks all rows" do
      assert Board.four_in_a_row?({nil, nil, nil, nil, 0, 2, 4, 8})
      assert Board.four_in_a_row?({nil, nil, nil, nil, nil, nil, nil, nil, 0, 2, 4, 8})

      assert Board.four_in_a_row?(
               {nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, 0, 2, 4, 8}
             )
    end

    test "checks all verticals" do
      assert Board.four_in_a_row?(
               {0, nil, nil, nil, 2, nil, nil, nil, 4, nil, nil, nil, 8, nil, nil, nil}
             )

      assert Board.four_in_a_row?(
               {nil, 0, nil, nil, nil, 2, nil, nil, nil, 4, nil, nil, nil, 8, nil, nil}
             )

      assert Board.four_in_a_row?(
               {nil, nil, 0, nil, nil, nil, 2, nil, nil, nil, 4, nil, nil, nil, 8, nil}
             )

      assert Board.four_in_a_row?(
               {nil, nil, nil, 0, nil, nil, nil, 2, nil, nil, nil, 4, nil, nil, nil, 8}
             )
    end

    test "checks all diagonals" do
      assert Board.four_in_a_row?(
               {0, nil, nil, nil, nil, 2, nil, nil, nil, nil, 4, nil, nil, nil, nil, 8}
             )

      assert Board.four_in_a_row?(
               {nil, nil, nil, 0, nil, nil, 2, nil, nil, 4, nil, nil, 8, nil, nil, nil}
             )
    end

    test "finds matching shorts on diagonal" do
      # 1011 1000 0001 1010
      assert Board.four_in_a_row?(
               {nil, nil, nil, 11, nil, nil, 8, nil, nil, 1, nil, nil, 9, nil, nil, nil}
             )
    end
  end
end
