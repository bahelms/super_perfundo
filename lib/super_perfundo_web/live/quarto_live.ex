defmodule SuperPerfundoWeb.QuartoLive do
  use SuperPerfundoWeb, :live_view
  alias SuperPerfundo.Quarto.{AI, Board}
  alias SuperPerfundoWeb.PieceComponent

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(
        board: Board.new(),
        active_player: :user,
        active_piece: nil,
        waiting_for_opponent: false,
        winning_state: false
      )

    {:ok, socket}
  end

  def handle_event("position_chosen", %{"position" => position}, socket) do
    position = String.to_integer(position)

    case Board.piece_at_position(socket.assigns.board, position) do
      nil ->
        {:noreply, set_piece(position, socket)}

      _ ->
        {:noreply, socket}
    end
  end

  def handle_event("piece_chosen", %{"piece" => piece}, socket) do
    socket =
      assign(socket,
        active_piece: String.to_integer(piece),
        active_player: :ai
      )

    send(self(), :ai_start)
    {:noreply, socket}
  end

  def handle_info(:ai_start, socket = %{assigns: %{board: board, active_piece: piece}}) do
    socket = assign(socket, waiting_for_opponent: true)
    {position, next_piece} = AI.choose_position_and_next_piece(board, piece)
    board = Board.set_piece(board, piece, position)
    winning_state = Board.four_in_a_row?(board)

    socket =
      assign(socket,
        board: board,
        active_piece: next_piece,
        active_player: if(winning_state, do: :ai, else: :user),
        waiting_for_opponent: false,
        winning_state: winning_state
      )

    {:noreply, socket}
  end

  defp display_player(:user), do: "You"
  defp display_player(:ai), do: "AI"

  defp set_piece(position, socket) do
    board =
      Board.set_piece(
        socket.assigns.board,
        socket.assigns.active_piece,
        position
      )

    assign(socket,
      board: board,
      active_piece: nil,
      winning_state: Board.four_in_a_row?(board)
    )
  end
end
