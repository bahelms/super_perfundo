defmodule SuperPerfundo.Quarto.AITest do
  use ExUnit.Case
  alias SuperPerfundo.Quarto.AI

  describe "choose_position_and_next_piece/2" do
    test "an index of the board is returned" do
      board = {nil, nil, 8, nil}
      {position, _piece} = AI.choose_position_and_next_piece(board, 10)
      assert position >= 0 && position < tuple_size(board)
      refute position == 2
    end

    test "an integer representing another piece is returned" do
      board = {nil, 1, nil, 5}
      {_position, piece} = AI.choose_position_and_next_piece(board, 10)
      assert piece >= 0 && piece < 16
      refute piece == 10
    end
  end

  describe "choose_next_piece/0" do
    test "a piece integer is randomly chosen" do
      piece = AI.choose_next_piece()
      assert piece >= 0 && piece < 16
    end
  end
end
