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
    use Mizur.System, intensive: true
    type celsius
    type farenheit = (celsius * 1.8) + 32.0
    type oth = 32 + (celsius * 1.8)
  end

  test "Simple Unwrapping" do 

    a = Temperature.celsius(1000)
    b = Distance.km(1234)
    c = Time.sec(2090)

    assert Mizur.unwrap(a) == 1000.0
    assert Mizur.unwrap(b) == 1234.0
    assert Mizur.unwrap(c) == 2090.0

  end

  test "Simple coercion" do 

    a = Temperature.celsius(1)
    b = Mizur.from(a, to: Temperature.farenheit)
    assert b == Temperature.farenheit((1-32.0)/1.8)

    c = Temperature.farenheit(1)
    d = Mizur.from(c, to: Temperature.celsius)
    assert d == Temperature.celsius(1*1.8 + 32.0)

    e = Distance.m(1)
    f = Mizur.from(e, to: Distance.cm)
    assert f == Distance.cm(100)

  end

  test "Coercion failure" do 
    message = "#{Distance} is not compatible with #{Temperature}"
    assert_raise RuntimeError, message, fn -> 
      _ = Mizur.from(Distance.km(10), to: Temperature.celsius)
    end
  end
  
  test "for infix version of from" do 
    import Mizur 
    a = Distance.km(2) ~> Distance.m
    assert a == Distance.m(2000)
  end
  
  

  
end
