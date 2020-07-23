defmodule SuperPerfundoWeb.QuartoLiveTest do
  use SuperPerfundoWeb.ConnCase
  alias SuperPerfundoWeb.QuartoLive

  test "highlight_for_win returns nil when position is not present" do
    assert QuartoLive.highlight_for_win([1, 2, 3, 4], 8) == nil
  end

  test "highlight_for_win returns CSS class name when position is present" do
    assert QuartoLive.highlight_for_win([1, 2, 3, 4], 3) == "slot-win"
  end

  test "highlight_for_win returns nil when win state is nil" do
    assert QuartoLive.highlight_for_win(nil, 3) == nil
  end
end
