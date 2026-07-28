defmodule SuperPerfundoWeb.PieceComponent do
  @moduledoc """
  Renders a Quarto piece.

  A function component rather than a LiveComponent: it holds no state and handles
  no events, and LiveView 1.0 requires every *stateful* component to have a single
  static HTML tag at its root -- which the empty (nil piece) case cannot satisfy.
  """
  use Phoenix.Component
  alias SuperPerfundo.Quarto.Board

  @doc """
  Accepts either `:board` + `:position`, or a raw `:piece` integer.
  """
  def piece(assigns) do
    resolved =
      if assigns[:board] do
        Board.piece_at_position(assigns.board, assigns.position)
      else
        Board.integer_to_piece(assigns[:piece])
      end

    assigns
    |> assign(:piece, resolved)
    |> render_piece()
  end

  defp render_piece(%{piece: nil} = assigns), do: ~H""

  defp render_piece(assigns) do
    ~H"""
    <div class="piece">
      <%= if @piece.shape == "cube" do %>
        <div class="cube">
          <div class={"side front #{@piece.size} #{@piece.color}"}></div>
          <div class={"side back #{@piece.size} #{@piece.color}"}></div>
          <div class={"side top #{@piece.size} #{@piece.color}"}></div>
          <div class={"side bottom #{@piece.size} #{@piece.color}"}></div>
          <div class={"side left #{@piece.size} #{@piece.color}"}></div>
          <div class={"side right #{@piece.size} #{@piece.color}"}></div>
          <%= if @piece.fill == "hollow" do %>
            <div class={"hollow #{@piece.size}"}></div>
          <% end %>
        </div>
      <% else %>
        <div class={"cylinder #{@piece.size}"}>
          <div class={"bottom #{@piece.size} #{@piece.color}"}></div>
          <div class={"middle #{@piece.size} #{@piece.color}"}></div>
          <div class={"top #{@piece.color}"}></div>
          <%= if @piece.fill == "hollow" do %>
            <div class="hollow"></div>
          <% end %>
        </div>
      <% end %>
    </div>
    """
  end
end
