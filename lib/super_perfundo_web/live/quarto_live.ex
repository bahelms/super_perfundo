defmodule SuperPerfundoWeb.QuartoLive do
  use SuperPerfundoWeb, :live_view
  alias SuperPerfundo.Quarto.Board
  alias SuperPerfundoWeb.PieceComponent

  def mount(_params, _session, socket) do
    socket =
      socket
      |> assign(board: Board.new(), active_player: :ai, active_piece: nil)

    {:ok, socket}
  end

  def render(assigns) do
    ~L"""
    <div id="board">
      <div class="row">
        <div class="slot" phx-click="choose_position">
          <%= live_component(@socket, PieceComponent, board: @board, position: 0) %>
        </div>
        <div class="slot" phx-click="choose_position">
          <%= live_component(@socket, PieceComponent, board: @board, position: 1) %>
        </div>
        <div class="slot" phx-click="choose_position">
          <%= live_component(@socket, PieceComponent, board: @board, position: 2) %>
        </div>
        <div class="slot" phx-click="choose_position">
          <%= live_component(@socket, PieceComponent, board: @board, position: 3) %>
        </div>
      </div>
      <div class="row">
        <div class="slot" phx-click="choose_position">
          <%= live_component(@socket, PieceComponent, board: @board, position: 4) %>
        </div>
        <div class="slot" phx-click="choose_position">
          <%= live_component(@socket, PieceComponent, board: @board, position: 5) %>
        </div>
        <div class="slot" phx-click="choose_position">
          <%= live_component(@socket, PieceComponent, board: @board, position: 6) %>
        </div>
        <div class="slot" phx-click="choose_position">
          <%= live_component(@socket, PieceComponent, board: @board, position: 7) %>
        </div>
      </div>
      <div class="row">
        <div class="slot" phx-click="choose_position">
          <%= live_component(@socket, PieceComponent, board: @board, position: 8) %>
        </div>
        <div class="slot" phx-click="choose_position">
          <%= live_component(@socket, PieceComponent, board: @board, position: 9) %>
        </div>
        <div class="slot" phx-click="choose_position">
          <%= live_component(@socket, PieceComponent, board: @board, position: 10) %>
        </div>
        <div class="slot" phx-click="choose_position">
          <%= live_component(@socket, PieceComponent, board: @board, position: 11) %>
        </div>
      </div>
      <div class="row">
        <div class="slot" phx-click="choose_position">
          <%= live_component(@socket, PieceComponent, board: @board, position: 12) %>
        </div>
        <div class="slot" phx-click="choose_position">
          <%= live_component(@socket, PieceComponent, board: @board, position: 13) %>
        </div>
        <div class="slot" phx-click="choose_position">
          <%= live_component(@socket, PieceComponent, board: @board, position: 14) %>
        </div>
        <div class="slot" phx-click="choose_position">
          <%= live_component(@socket, PieceComponent, board: @board, position: 15) %>
        </div>
      </div>
    </div>
    """
  end

  def handle_event("choose_position", _, socket) do
    {:noreply, socket}
  end
end
