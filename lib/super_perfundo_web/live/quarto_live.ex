defmodule SuperPerfundoWeb.QuartoLive do
  use SuperPerfundoWeb, :live_view
  alias SuperPerfundo.Quarto.{AI, Board, Game}
  alias SuperPerfundoWeb.PieceComponent

  def mount(_params, _session, socket) do
    socket =
      assign(socket,
        board: Board.new(),
        active_player: nil,
        active_piece: nil,
        winning_state: nil,
        game_start: true,
        chosen_player: Game.choose_player()
      )

    {:ok, socket}
  end

  def handle_event("start_game", _, socket = %{assigns: %{chosen_player: chosen_player}}) do
    if chosen_player == :ai do
      send(self(), :ai_start)
    end

    {:noreply, assign(socket, game_start: false, active_player: chosen_player)}
  end

  def handle_event("position_chosen", %{"position" => position}, socket) do
    new_assigns =
      String.to_integer(position)
      |> Game.position_chosen(socket.assigns)
      |> Map.to_list()

    {:noreply, assign(socket, new_assigns)}
  end

  def handle_event("piece_chosen", %{"piece" => piece}, socket) do
    with nil <- socket.assigns.winning_state,
         nil <- socket.assigns.active_piece do
      send(self(), :ai_start)

      {:noreply,
       assign(socket,
         active_piece: String.to_integer(piece),
         active_player: :ai
       )}
    else
      _ ->
        {:noreply, socket}
    end
  end

  def handle_info(:ai_start, socket = %{assigns: %{active_piece: nil}}) do
    {:noreply, assign(socket, active_piece: AI.choose_next_piece(), active_player: :user)}
  end

  def handle_info(:ai_start, socket = %{assigns: %{board: board, active_piece: piece}}) do
    {position, next_piece} = AI.choose_position_and_next_piece(board, piece)
    board = Board.set_piece(board, piece, position)
    winning_state = Board.four_in_a_row?(board)

    socket =
      assign(socket,
        board: board,
        active_piece: if(winning_state, do: nil, else: next_piece),
        active_player: if(winning_state, do: :ai, else: :user),
        winning_state: winning_state
      )

    {:noreply, socket}
  end

  defp choose_piece?(:user, nil, winning_state) do
    if !winning_state do
      "raise-box"
    else
      nil
    end
  end

  defp choose_piece?(_, _, _), do: nil

  def highlight_for_win(nil, _), do: nil

  def highlight_for_win(win_state, position) do
    if Enum.member?(win_state, position) do
      "slot-win"
    end
  end

  defp display_player(:user), do: "You"
  defp display_player(:ai), do: "AI"
  defp display_player(nil), do: nil

  defp display_coin_toss_winner(:ai), do: "Your opponent won the coin toss. They play first."
  defp display_coin_toss_winner(:user), do: "You won the coin toss! You play first."
end
