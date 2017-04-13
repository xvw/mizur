defmodule MizurTest do
  use ExUnit.Case
  doctest Mizur

  defmodule Length do 
    use Mizur
    type :cm
    type :mm = :cm / 10
    type :dm = 10 * :cm
    type :m  = :dm * 10
    type :km = :m * 1000
  end

  defmodule Money do 
    use Mizur
    type :euro
    type :dollar = :euro * 1.06665
  end

  defmodule Test do 
    use Mizur 
    v_type :celsius
    v_type :farenheit = :celsius * 1.8 + 32.0
  end

  IO.inspect Test.celsius(12)

  
end
