defmodule MizurTest do
  use ExUnit.Case
  doctest Mizur

  defmodule Test do 
    use Mizur.System

    type celsius
    type farenheit = celsius * 1.8 + 32.0
    type oth = 32 + (celsius * 1.8)

  end

  {_, _, b, a} = Test.farenheit
  IO.inspect (b.(1))

  
end
