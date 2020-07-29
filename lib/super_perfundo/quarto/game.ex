defmodule SuperPerfundo.Quarto.Game do
  alias SuperPerfundo.Quarto.Board

  def choose_player, do: Enum.random([:ai, :user])

  def position_chosen(position, state) do
    with nil <- state.winning_state,
         nil <- Board.piece_at_position(state.board, position) do
      set_piece(state, position)
    else
      _ ->
        state
    end
  end

  defp set_piece(state, position) do
    board = Board.set_piece(state.board, state.active_piece, position)
    %{board: board, active_piece: nil, winning_state: Board.four_in_a_row?(board)}
  end
end
