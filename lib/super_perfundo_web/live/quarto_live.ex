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
        active_piece: 4,
        waiting_for_opponent: false
      )

    {:ok, socket}
  end

  def render(assigns) do
    ~L"""
    <div id="game">
      <div class="player-status">
        Current Player: <%= @active_player %>
        <div class="active-piece">
          Active Piece
          <%= live_component(@socket, PieceComponent, piece: @active_piece) %>
        </div>
      </div>

      <div id="board">
        <div class="row">
          <div class="slot" phx-click="position_chosen" phx-value-position="0">
            <%= live_component(@socket, PieceComponent, board: @board, position: 0) %>
          </div>
          <div class="slot" phx-click="position_chosen" phx-value-position="1">
            <%= live_component(@socket, PieceComponent, board: @board, position: 1) %>
          </div>
          <div class="slot" phx-click="position_chosen" phx-value-position="2">
            <%= live_component(@socket, PieceComponent, board: @board, position: 2) %>
          </div>
          <div class="slot" phx-click="position_chosen" phx-value-position="3">
            <%= live_component(@socket, PieceComponent, board: @board, position: 3) %>
          </div>
        </div>
        <div class="row">
          <div class="slot" phx-click="position_chosen" phx-value-position="4">
            <%= live_component(@socket, PieceComponent, board: @board, position: 4) %>
          </div>
          <div class="slot" phx-click="position_chosen" phx-value-position="5">
            <%= live_component(@socket, PieceComponent, board: @board, position: 5) %>
          </div>
          <div class="slot" phx-click="position_chosen" phx-value-position="6">
            <%= live_component(@socket, PieceComponent, board: @board, position: 6) %>
          </div>
          <div class="slot" phx-click="position_chosen" phx-value-position="7">
            <%= live_component(@socket, PieceComponent, board: @board, position: 7) %>
          </div>
        </div>
        <div class="row">
          <div class="slot" phx-click="position_chosen" phx-value-position="8">
            <%= live_component(@socket, PieceComponent, board: @board, position: 8) %>
          </div>
          <div class="slot" phx-click="position_chosen" phx-value-position="9">
            <%= live_component(@socket, PieceComponent, board: @board, position: 9) %>
          </div>
          <div class="slot" phx-click="position_chosen" phx-value-position="10">
            <%= live_component(@socket, PieceComponent, board: @board, position: 10) %>
          </div>
          <div class="slot" phx-click="position_chosen" phx-value-position="11">
            <%= live_component(@socket, PieceComponent, board: @board, position: 11) %>
          </div>
        </div>
        <div class="row">
          <div class="slot" phx-click="position_chosen" phx-value-position="12">
            <%= live_component(@socket, PieceComponent, board: @board, position: 12) %>
          </div>
          <div class="slot" phx-click="position_chosen" phx-value-position="13">
            <%= live_component(@socket, PieceComponent, board: @board, position: 13) %>
          </div>
          <div class="slot" phx-click="position_chosen" phx-value-position="14">
            <%= live_component(@socket, PieceComponent, board: @board, position: 14) %>
          </div>
          <div class="slot" phx-click="position_chosen" phx-value-position="15">
            <%= live_component(@socket, PieceComponent, board: @board, position: 15) %>
          </div>
        </div>
      </div>

      <%= if @active_player == :user && !@active_piece do %>
        <div class="modal">
          <div class="modal-content">
            <div>Select the piece for me to play:</div>
            <div class="remaining-pieces">
              <%= for piece <- Board.remaining_pieces(@board) do %>
                <div phx-click="piece_chosen" phx-value-piece="<%= piece %>">
                  <%= live_component(@socket, PieceComponent, piece: piece) %>
                </div>
              <% end %>
            </div>
          </div>
        </div>
      <% end %>
    </div>
    """
  end

  def handle_event("position_chosen", %{"position" => position}, socket) do
    board =
      Board.set_piece(
        socket.assigns.board,
        socket.assigns.active_piece,
        String.to_integer(position)
      )

    # check winning state
    socket =
      assign(socket,
        board: board,
        active_piece: nil
      )

    {:noreply, socket}
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
    # check winning state

    socket =
      assign(socket,
        board: Board.set_piece(board, piece, position),
        active_piece: next_piece,
        active_player: :user,
        waiting_for_opponent: false
      )

    {:noreply, socket}
  end
end
