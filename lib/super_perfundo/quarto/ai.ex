defmodule SuperPerfundo.Quarto.AI do
  alias SuperPerfundo.Quarto.Board
  use Rustler, otp_app: :super_perfundo, crate: "quarto_ai"

  def choose_position_and_next_piece(_board, _active_piece),
    do: :erlang.nif_error(:nif_not_loaded)

  def choose_next_piece do
    Board.all_pieces_set()
    |> Enum.take_random(1)
    |> List.first()
  end
end
