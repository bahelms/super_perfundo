defmodule SuperPerfundoWeb.QuartoLive do
  use SuperPerfundoWeb, :live_view

  def render(assigns) do
    ~L"""
    <div id="board">
      <div class="row">
        <div class="slot">
          <div class="cube">
            <div class="side front short dark"></div>
            <div class="side back short dark"></div>
            <div class="side top short dark"></div>
            <div class="side bottom short dark"></div>
            <div class="side left short dark"></div>
            <div class="side right short dark"></div>
          </div>
        </div>
        <div class="slot">
          <div class="cube">
            <div class="side front tall light"></div>
            <div class="side back tall light"></div>
            <div class="side top tall light"></div>
            <div class="side bottom tall light"></div>
            <div class="side left tall light"></div>
            <div class="side right tall light"></div>
          </div>
        </div>
        <div class="slot">
          <div class="cube">
            <div class="side front tall dark"></div>
            <div class="side back tall dark"></div>
            <div class="side top tall dark"></div>
            <div class="side bottom tall dark"></div>
            <div class="side left tall dark"></div>
            <div class="side right tall dark"></div>
          </div>
        </div>
        <div class="slot">
          <div class="cube">
            <div class="side front short light"></div>
            <div class="side back short light"></div>
            <div class="side top short light"></div>
            <div class="side bottom short light"></div>
            <div class="side left short light"></div>
            <div class="side right short light"></div>
          </div>
        </div>
      </div>
      <div class="row">
        <div class="slot">
          <div class="cube">
            <div class="side front tall light"></div>
            <div class="side back tall light"></div>
            <div class="side top tall light"></div>
            <div class="side bottom tall light"></div>
            <div class="side left tall light"></div>
            <div class="side right tall light"></div>
            <div class="hollow tall"></div>
          </div>
        </div>
        <div class="slot">
          <div class="cube">
            <div class="side front short dark"></div>
            <div class="side back short dark"></div>
            <div class="side top short dark"></div>
            <div class="side bottom short dark"></div>
            <div class="side left short dark"></div>
            <div class="side right short dark"></div>
            <div class="hollow short"></div>
          </div>
        </div>
        <div class="slot">
          <div class="cube">
            <div class="side front short light"></div>
            <div class="side back short light"></div>
            <div class="side top short light"></div>
            <div class="side bottom short light"></div>
            <div class="side left short light"></div>
            <div class="side right short light"></div>
            <div class="hollow short"></div>
          </div>
        </div>
        <div class="slot">
          <div class="cube">
            <div class="side front tall dark"></div>
            <div class="side back tall dark"></div>
            <div class="side top tall dark"></div>
            <div class="side bottom tall dark"></div>
            <div class="side left tall dark"></div>
            <div class="side right tall dark"></div>
            <div class="hollow tall"></div>
          </div>
        </div>
      </div>
      <div class="row">
        <div class="slot">
          <div class="cylinder tall">
            <div class="bottom tall dark"></div>
            <div class="middle tall dark"></div>
            <div class="top dark"></div>
          </div>
        </div>
        <div class="slot">
          <div class="cylinder short">
            <div class="bottom short dark"></div>
            <div class="middle short dark"></div>
            <div class="top dark"></div>
          </div>
        </div>
        <div class="slot">
          <div class="cylinder tall">
            <div class="bottom tall light"></div>
            <div class="middle tall light"></div>
            <div class="top light"></div>
          </div>
        </div>
        <div class="slot">
          <div class="cylinder short">
            <div class="bottom short light"></div>
            <div class="middle short light"></div>
            <div class="top light"></div>
          </div>
        </div>
      </div>
      <div class="row">
        <div class="slot">
          <div class="cylinder short">
            <div class="bottom short light"></div>
            <div class="middle short light"></div>
            <div class="top light"></div>
            <div class="hollow"></div>
          </div>
        </div>
        <div class="slot">
          <div class="cylinder tall">
            <div class="bottom tall light"></div>
            <div class="middle tall light"></div>
            <div class="top light"></div>
            <div class="hollow"></div>
          </div>
        </div>
        <div class="slot">
          <div class="cylinder tall">
            <div class="bottom tall dark"></div>
            <div class="middle tall dark"></div>
            <div class="top dark"></div>
            <div class="hollow"></div>
          </div>
        </div>
        <div class="slot">
          <div class="cylinder short">
            <div class="bottom short dark"></div>
            <div class="middle short dark"></div>
            <div class="top dark"></div>
            <div class="hollow"></div>
          </div>
        </div>
      </div>
    </div>
    """
  end
end
