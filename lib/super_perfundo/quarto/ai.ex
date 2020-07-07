defmodule SuperPerfundo.Quarto.AI do
  alias SuperPerfundo.Quarto.Board

  @doc """
  Easiest AI ever! This picks a random position for the given piece and a random
  piece to use next.
  """
  def choose_position_and_next_piece(board, piece) do
    position =
      board
      |> open_positions()
      |> Enum.take_random(1)
      |> List.first()

    next_piece =
      board
      |> remaining_pieces(piece)
      |> Enum.take_random(1)
      |> List.first()

    {position, next_piece}
  end

  defp open_positions(board) do
    for index <- 0..15, !elem(board, index), do: index
  end

  defp remaining_pieces(board, piece) do
    board
    |> Board.remaining_pieces()
    |> MapSet.difference(MapSet.new([piece]))
  end
end
