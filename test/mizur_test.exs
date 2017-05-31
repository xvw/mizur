defmodule MizurTest do
  use ExUnit.Case
  doctest Mizur

  defmodule Length do 
    use Mizur.System
  end

  test "experience" do 
    x = %Length.Type{name: :cm, from_basis: 0, to_basis: 0}
    y = %Length{type: x, value: 32.0}
    IO.inspect y
  end
  
end
