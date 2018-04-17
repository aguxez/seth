defmodule SethTest do
  use ExUnit.Case
  doctest Seth

  test "greets the world" do
    assert Seth.hello() == :world
  end
end
