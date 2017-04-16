defmodule MizurTest do
  use ExUnit.Case
  doctest Mizur

  defmodule Test do 
    use Mizur 
    type celsius
    type farenheit = celsius * 1.8 + 32.0
  end

  IO.inspect Test.farenheit
  
end
