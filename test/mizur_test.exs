defmodule MizurTest do
  use ExUnit.Case
  doctest Mizur

  defmodule Length do 
    use Mizur.System
    type m
    type mm
    type dm = m / 10
  end

  test "experience" do 
    x = %Length.Type{name: :cm, from_basis: 0, to_basis: 0}
    _y = %Length{type: x, value: 32.0}
    IO.inspect Length.m.from_basis.(12)
  end
  
end
