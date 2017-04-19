defmodule MizurTest do
  use ExUnit.Case
  doctest Mizur


  defmodule Distance do 
    use Mizur.System 

    type m
    type cm = m / 100 
    type mm = m / 1000 
    type km = m * 1000

  end

  defmodule Time do 
    use Mizur.System 

    type sec
    type min  = sec * 60 
    type hour = 60 * 60 * sec
    type day  = 60 * sec * (60 * 24)

  end
  
  defmodule Temperature do 
    use Mizur.System

    type celsius
    type farenheit = (celsius * 1.8) + 32.0
    type oth = 32 + (celsius * 1.8)
  end

  IO.inspect (Mizur.from(Distance.m(1000), to: Distance.km))

  
end
