defmodule SuperPerfundo.Quarto.Game do
  def choose_player do
    Enum.random([:ai, :user])
  end
end
