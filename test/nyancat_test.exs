defmodule NyancatTest do
  use ExUnit.Case
  doctest Nyancat

  test "greets the world" do
    assert Nyancat.hello() == :world
  end
end
