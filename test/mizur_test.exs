defmodule MizurTest do
  use ExUnit.Case
  doctest Mizur

  defmodule Length do 
    use Mizur.System
    type m
    type mm
    type cm = m / 100
    type dm = cm * 10
  end

  test "experience" do 
    import Length
    x = ~M(100)dm
    IO.inspect x 
  end
  
end
