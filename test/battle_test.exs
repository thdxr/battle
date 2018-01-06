defmodule BattleTest do
  use ExUnit.Case
  doctest Battle

  test "greets the world" do
    assert Battle.hello() == :world
  end
end
