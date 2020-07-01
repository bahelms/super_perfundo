defmodule SuperPerfundoWeb.QuartoLive do
  use SuperPerfundoWeb, :live_view

  def render(assigns) do
    ~L"""
    <div id="board">
      <div class="row">
        <div class="slot">
           <div class="cube short">
             <div class="side front color-dark"></div>
             <div class="side top color-dark"></div>
             <div class="side left color-dark"></div>
           </div>
        </div>
        <div class="slot">
           <div class="cube tall">
             <div class="side front color-light"></div>
             <div class="side top color-light"></div>
             <div class="side left color-light"></div>
           </div>
        </div>
        <div class="slot"></div>
        <div class="slot"></div>
      </div>
      <div class="row">
        <div class="slot"></div>
        <div class="slot"></div>
        <div class="slot"></div>
        <div class="slot"></div>
      </div>
      <div class="row">
        <div class="slot"></div>
        <div class="slot"></div>
        <div class="slot"></div>
        <div class="slot"></div>
      </div>
      <div class="row">
        <div class="slot"></div>
        <div class="slot"></div>
        <div class="slot"></div>
        <div class="slot"></div>
      </div>
    </div>
    """
  end
end
