defmodule MizurTest do
  use ExUnit.Case
  doctest Mizur
  #doctest Mizur.Length # To be erased

  defmodule Length do 
    use Mizur
    type m 
    type dm = m / 10 
    type cm = dm / (2*5)
    type mm = 10 / cm
  end

  defmodule Temperature do 
    use Mizur
    type celsius
    type fahrenheit = (1.8 * celsius) + 32
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
    a = Temperature.celsius.to_basis.(10)
    b = Temperature.celsius.from_basis.(17)
    assert a == 10.0
    assert b == 17.0
    a = Temperature.fahrenheit.to_basis.(0)
    assert a == 32
    b = Temperature.fahrenheit.to_basis.(1)
    assert b == 33.8
    c = Temperature.fahrenheit.from_basis.(1)
    assert c == (1-32.0)/1.8
    d = Temperature.fahrenheit.from_basis.(2)
    assert d == (2-32.0)/1.8
  end

  test "Test simple conversion" do 
    Length.m(12)
    |> Length.from(to: Length.cm)
    |> Length.to_float
    |> Kernel.==(1200.0)
    |> assert
  end

  test "Simple coercion" do 

    a = Temperature.celsius(1)
    b = Temperature.from(a, to: Temperature.fahrenheit)
    assert b == Temperature.fahrenheit((1-32.0)/1.8)

    c = Temperature.fahrenheit(1)
    d = Temperature.from(c, to: Temperature.celsius)
    assert d == Temperature.celsius(1*1.8 + 32.0)

    e = Length.m(1)
    f = Length.from(e, to: Distance.cm)
    assert f == Length.cm(100)

end

end
