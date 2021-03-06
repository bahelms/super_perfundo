defmodule SuperPerfundoWeb.PieceComponent do
  use SuperPerfundoWeb, :live_component
  alias SuperPerfundo.Quarto.Board

  def update(assigns, socket) do
    piece =
      if assigns[:board] do
        Board.piece_at_position(assigns.board, assigns.position)
      else
        Board.integer_to_piece(assigns.piece)
      end

    {:ok, assign(socket, :piece, piece)}
  end

  def render(assigns = %{piece: nil}), do: ~L""

  def render(assigns) do
    ~L"""
    <div class="piece">
      <%= if @piece.shape == "cube" do %>
        <div class="cube">
          <div class="side front <%= @piece.size %> <%= @piece.color %>"></div>
          <div class="side back <%= @piece.size %> <%= @piece.color %>"></div>
          <div class="side top <%= @piece.size %> <%= @piece.color %>"></div>
          <div class="side bottom <%= @piece.size %> <%= @piece.color %>"></div>
          <div class="side left <%= @piece.size %> <%= @piece.color %>"></div>
          <div class="side right <%= @piece.size %> <%= @piece.color %>"></div>
          <%= if @piece.fill == "hollow" do %>
            <div class="hollow <%= @piece.size %>"></div>
          <% end %>
        </div>
      <% else %>
        <div class="cylinder <%= @piece.size %>">
          <div class="bottom <%= @piece.size %> <%= @piece.color %>"></div>
          <div class="middle <%= @piece.size %> <%= @piece.color %>"></div>
          <div class="top <%= @piece.color %>"></div>
          <%= if @piece.fill == "hollow" do %>
            <div class="hollow"></div>
          <% end %>
        </div>
      <% end %>
    </div>
    """
  end
end
