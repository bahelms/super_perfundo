defmodule SuperPerfundo.Quarto.Game do
  alias SuperPerfundo.Quarto.Board

  @state_keys [:board, :active_piece, :active_player, :winning_state, :draw]

  def choose_player, do: Enum.random([:ai, :user])

  def position_chosen(position, state) do
    with nil <- state.winning_state,
         nil <- Board.piece_at_position(state.board, position) do
      set_piece(state, position)
    else
      # Only hand back the keys we own. The caller merges this into the
      # LiveView assigns, which also hold reserved keys like :flash.
      _ ->
        Map.take(state, @state_keys)
    end
  end

  defp set_piece(state, position) do
    board = Board.set_piece(state.board, state.active_piece, position)
    winning_state = Board.four_in_a_row?(board)
    draw = is_nil(winning_state) && Board.full?(board)

    %{
      board: board,
      active_piece: nil,
      # Nobody is on the clock once the board fills up with no winner.
      active_player: if(draw, do: nil, else: state.active_player),
      winning_state: winning_state,
      draw: draw
    }
  end
end
