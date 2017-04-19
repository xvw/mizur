defmodule MizurTest do
  use ExUnit.Case
  doctest Mizur

  defmodule Test do 
    use Mizur 

    type celsius
    type farenheit = celsius * 1.8 + 32.0
    type cm = 18

  end

  {_, _, b, a} = Test.farenheit
  IO.inspect (a.(1))

  
end
