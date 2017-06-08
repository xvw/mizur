defmodule MizurTest do
  use ExUnit.Case
  doctest Mizur
  #doctest Mizur.Length # To be erased

  defmodule Length do 
    use Mizur
    type m 
    type dm = m / 10 
    type cm = dm / (2*5)
  end

  defmodule Temperature do 
    use Mizur
    type celsius
    type fahrenheit = (celsius - 32) / 1.8
  end

  defmodule Chrono do 
    use Mizur
    type sec 
    type min = sec * 60 
    type hour = min * 60 
    type day = hour * 24
  end

  test "from and to basis for Length 1" do 
    a = Length.m.to_basis.(123)
    b = Length.m.from_basis.(126)
    assert a == 123.0 
    assert b == 126.0
  end

  test "from and to basis for Length 2" do 
    c = Length.cm.to_basis.(12300)
    d = Length.cm.from_basis.(12)
    assert c == 123.0 
    assert d == 1200.0
  end
  
  test "from and to basis for length 3" do 
    e = Length.dm.to_basis.(10)
    f = Length.dm.from_basis.(10)
    assert e == 1.0 
    assert f == 100.0
  end

  test "for temperature 1" do 
    a = Temperature.celsius.to_basis.(1234)
    assert a == 1234
  end

  test "for temperature 2" do 
    a = Temperature.celsius.from_basis.(61234)
    assert a == 61234
  end

  test "for temperature (more complexe example) 1 : to_basis" do 
    a = Temperature.fahrenheit.to_basis.(1)
    assert a == (1 - 32)/1.8
  end

  test "for temperature (more complexe example) 2 : to_basis" do 
    a = Temperature.fahrenheit.to_basis.(2)
    assert a == (2 - 32)/1.8
  end

  test "for temperature (more complexe example) 3 : to_basis" do 
    a = Temperature.fahrenheit.to_basis.(3)
    assert a == (3 - 32)/1.8
  end


  test "for temperature (more complexe example) : from_basis" do 
    a = Temperature.fahrenheit.from_basis.(1)
    assert a == 32 + (1*1.8)
  end

  test "for temperature (more complexe example) 2 : from_basis" do 
    a = Temperature.fahrenheit.from_basis.(2)
    assert a == 32 + (2*1.8)
  end

  test "for temperature (more complexe example) 3 : from_basis" do 
    a = Temperature.fahrenheit.from_basis.(3)
    assert a == 32 + (3*1.8)
  end



  test "for Chrono" do 
    a = Chrono.hour.to_basis.(2)
    assert a == 7200.0
  end
  


  test "Simple conversion with float 1" do 
    a = Length.m(12)
    |> Length.from(to: Length.cm)
    |> Length.to_float
    assert a == 1200.0
  end

  test "for macros" do 
    import Length
    c = cm(12)

    case c do 
      x when is_cm(x) -> IO.inspect "lol"
      _ -> IO.inspect "snif"
    end 
    
  end
  



end
