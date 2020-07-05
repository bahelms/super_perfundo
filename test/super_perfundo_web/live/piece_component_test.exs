defmodule SuperPerfundoWeb.PieceComponentTest do
  use SuperPerfundoWeb.ConnCase
  import Phoenix.LiveViewTest
  alias SuperPerfundoWeb.PieceComponent

  test "nil returns empty string" do
    assert render_component(PieceComponent, board: {nil}, position: 0) == ""
  end

  @tag :skip
  test "HTML for a tall, dark, solid cube" do
    assert render_component(PieceComponent, board: {5}, position: 0) =~ """

             <div class="cube">
               <div class="side front tall dark"></div>
               <div class="side back tall dark"></div>
               <div class="side top tall dark"></div>
               <div class="side bottom tall dark"></div>
               <div class="side left tall dark"></div>
               <div class="side right tall dark"></div>

             </div>

           """
  end

  # describe "render/1" do

  #   test "HTML for a short, light, hollow cube" do
  #     piece = %Piece{shape: "cube", fill: "hollow", color: "light", size: "short"}

  #     assert QuartoLive.to_html(piece) == """
  #            <div class="cube">
  #              <div class="side front short light"></div>
  #              <div class="side back short light"></div>
  #              <div class="side top short light"></div>
  #              <div class="side bottom short light"></div>
  #              <div class="side left short light"></div>
  #              <div class="side right short light"></div>
  #              <div class="hollow short"></div>
  #            </div>
  #            """
  #   end
  # end
end
