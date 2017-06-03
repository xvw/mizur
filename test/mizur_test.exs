defmodule MizurTest do
  use ExUnit.Case
  doctest Mizur
  #doctest Mizur.Length # To be erased

  defmodule Length do 
    use Mizur.System
    type m 
    type dm = m / 10 
    type cm = dm / 10 
    type mm = 10 / cm
  end

  defmodule Temperature do 
    use Mizur.System
    type farenheit
    type celsius = 32.0 + (farenheit * 1.8)
  end

  test "from and to basis for Length" do 
    a = Length.m.to_basis.(123)
    b = Length.m.from_basis.(126)
    assert a == 123.0 
    assert b == 126.0
    c = Length.cm.to_basis.(12300)
    d = Length.cm.from_basis.(12)
    assert c == 123.0 
    assert d == 1200.0
    e = Length.dm.to_basis.(10)
    f = Length.dm.from_basis.(10)
    assert e == 1.0 
    assert f == 100.0
  end

  test "from and to basis for Temperature" do 
    a = Temperature.farenheit.to_basis.(10)
    b = Temperature.farenheit.from_basis.(17)
    assert a == 10.0
    assert b == 17.0
    a = Temperature.celsius.to_basis.(0)
    assert a == 32
    b = Temperature.celsius.to_basis.(1)
    assert b == 33.8
    c = Temperature.celsius.from_basis.(1)
    IO.inspect c
  end

  
end
