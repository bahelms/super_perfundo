defmodule SuperPerfundo.Quarto.Board do
  @moduledoc """
  Pieces on the board are represented as integers at positions in a tuple.
  Binary representation of those integers is encoded as follows:
    4 bits covering 0 - 15 (0000 - 1111)
    `nil` represents no piece.

    These bits represent the binary properties of a piece.

    Shape Size Fill Color
    0     0    0    0

    Shape:
      0 -> cube
      1 -> cylinder
    Size:
      0 -> short
      1 -> tall
    Fill:
      0 -> solid
      1 -> hollow
    Color:
      0 -> light
      1 -> dark

    Thus 1100 is a cylinder, tall, solid, light piece.
  """

  alias SuperPerfundo.Quarto.Piece

  @property_map %{
    shape: %{"0" => "cube", "1" => "cylinder"},
    size: %{"0" => "short", "1" => "tall"},
    fill: %{"0" => "solid", "1" => "hollow"},
    color: %{"0" => "light", "1" => "dark"}
  }
  @all_pieces_set MapSet.new([0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15])

  def new do
    {nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil}
  end

  def integer_to_piece(nil), do: nil

  def integer_to_piece(int) do
    int
    |> int_to_nibble()
    |> nibble_to_piece()
  end

  defp int_to_nibble(int) do
    int
    |> Integer.to_string(2)
    |> String.pad_leading(4, "0")
  end

  defp nibble_to_piece(<<shape, size, fill, color>>) do
    %Piece{
      shape: @property_map.shape[<<shape>>],
      size: @property_map.size[<<size>>],
      fill: @property_map.fill[<<fill>>],
      color: @property_map.color[<<color>>]
    }
  end

  def piece_at_position(board, position) do
    case elem(board, position) do
      nil ->
        nil

      int ->
        integer_to_piece(int)
    end
  end

  def set_piece(board, piece, position) do
    put_elem(board, position, piece)
  end

  def remaining_pieces(board) do
    MapSet.difference(@all_pieces_set, current_pieces_set(board))
  end

  def current_pieces_set(board) do
    for position <- 0..15,
        piece = elem(board, position),
        piece != nil,
        do: piece,
        into: MapSet.new()
  end
end
