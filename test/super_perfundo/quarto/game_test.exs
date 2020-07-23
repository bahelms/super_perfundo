defmodule SuperPerfundo.Quarto.GameTest do
  use ExUnit.Case
  alias SuperPerfundo.Quarto.Game

  test "choose_player returns :ai or :user" do
    assert Enum.member?([:ai, :user], Game.choose_player())
  end
end
