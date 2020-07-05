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

  def new do
    # {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15}
    {nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil}
  end

  def piece_at_position(board, position) do
    case elem(board, position) do
      nil ->
        nil

      int ->
        int
        |> Integer.to_string(2)
        |> String.pad_leading(4, "0")
        |> bits_to_piece()
    end
  end

  def set_piece(board, piece, position) do
    put_elem(board, position, piece)
  end

  defp bits_to_piece(<<shape, size, fill, color>>) do
    %Piece{
      shape: @property_map.shape[<<shape>>],
      size: @property_map.size[<<size>>],
      fill: @property_map.fill[<<fill>>],
      color: @property_map.color[<<color>>]
    }
  end
end
