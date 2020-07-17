defmodule SuperPerfundoWeb.StartModalComponent do
  use SuperPerfundoWeb, :live_component
  alias SuperPerfundo.Quarto.Game

  def mount(socket) do
    {:ok, assign(socket, game_start: true, chosen_player: Game.choose_player())}
  end

  def render(assigns) do
    ~L"""
    <%= if @game_start do %>
      <div id="game-start-modal">
        <div class="modal-content">
          <h3><%= display_winner(@chosen_player) %></h3>
          <button phx-click="start_game" phx-target="<%= @myself %>">Game on!</button>
        </div>
      </div>
      <div class="blackout" />
    <% end %>
    """
  end

  def handle_event("start_game", _, socket) do
    send(self(), {:player_chosen, socket.assigns.chosen_player})
    {:noreply, assign(socket, :game_start, false)}
  end

  defp display_winner(:ai), do: "Your opponent won the coin toss. They play first."
  defp display_winner(:user), do: "You won the coin toss! You play first."
end
