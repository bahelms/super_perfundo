defmodule SuperPerfundoWeb.QuartoLive do
  use SuperPerfundoWeb, :live_view
  alias SuperPerfundo.Quarto.{AI, Board}
  alias SuperPerfundoWeb.{PieceComponent, StartModalComponent}

  def mount(_params, _session, socket) do
    socket =
      assign(socket,
        board: Board.new(),
        active_player: nil,
        active_piece: nil,
        winning_state: nil
      )

    {:ok, socket}
  end

  def handle_event("position_chosen", %{"position" => position}, socket) do
    case socket.assigns.winning_state do
      nil ->
        position = String.to_integer(position)

        case Board.piece_at_position(socket.assigns.board, position) do
          nil ->
            {:noreply, set_piece(position, socket)}

          _ ->
            {:noreply, socket}
        end

      _ ->
        {:noreply, socket}
    end
  end

  def handle_event("piece_chosen", %{"piece" => piece}, socket) do
    case socket.assigns.winning_state do
      nil ->
        socket =
          case socket.assigns.active_piece do
            nil ->
              send(self(), :ai_start)

              assign(socket,
                active_piece: String.to_integer(piece),
                active_player: :ai
              )

            _ ->
              socket
          end

        {:noreply, socket}

      _ ->
        {:noreply, socket}
    end
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

    IO.inspect(socket.assigns, label: "assigns")

    {:noreply, socket}
  end

  def handle_info({:player_chosen, player}, socket) do
    {:noreply, assign(socket, :active_player, player)}
  end

  defp display_player(:user), do: "You"
  defp display_player(:ai), do: "AI"
  defp display_player(nil), do: nil

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

  defp choose_piece?(:user, nil, winning_state) do
    IO.inspect(winning_state, label: "choose piece? winning_state")

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
end