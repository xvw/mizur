defmodule MizurTest do
  use ExUnit.Case
  doctest Mizur

  defmodule Length do 
    use Mizur
    type cm
    type mm = cm / 10
    type dm = 10 * cm
  end

  defmodule Test do 
    use Mizur 
    type celsius
    type farenheit = celsius * 1.8 + 32.0
  end

  {_, _, x} = Length.mm
  IO.inspect x.(100)

  
end
