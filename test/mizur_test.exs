defmodule MizurTest do
  use ExUnit.Case
  doctest Mizur
  #doctest Mizur.Length # To be erased


  defmodule Length do 
    use Mizur
    type m 
    type dm = (1 / 10) * m
    type cm = m / 100
    type mm = cm / 10
    type km = 1000 * m
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
    |> Length.to_float()
    assert a == 1200.0
  end

  test "Simple conversion with mm" do 
    a = Length.m(12)
    |> Length.from(to: Length.mm)
    |> Length.to_float()
    assert a == 12000.0
  end

  test "Simple conversion with km" do 
    a = Length.km(12)
    |> Length.from(to: Length.m)
    |> Length.to_float()
    assert a == 12000.0
  end

  test "From with temperatures" do 
    a = Temperature.celsius(10)
    |> Temperature.from(to: Temperature.fahrenheit)
    |> Temperature.to_float()
    assert a == 50.0
  end

  test "From with chrono 1" do 
    a = Chrono.sec(60)
    b = Chrono.from(a, to: Chrono.min)
    |> Chrono.to_float()
    assert b == 1.0
  end

  test "From with chrono 2" do 
    a = Chrono.min(60)
    b = Chrono.from(a, to: Chrono.hour)
    |> Chrono.to_float()
    assert b == 1.0
  end

  test "From with chrono 3" do 
    a = Chrono.hour(1)
    b = Chrono.from(a, to: Chrono.sec)
    |> Chrono.to_float()
    assert b == 3600.0
  end

  test "map simple 1" do 
    a = Chrono.hour(2)
    |> Chrono.map(fn(x) -> x / 2 end)
    |> Chrono.from(to: Chrono.min)
    |> Chrono.to_float()
    assert a == 60.0
  end
  

  test "map2 simple 1" do 
    a = Chrono.sec(1000)
    b = Chrono.hour(1)
    c = 
      Chrono.map2(a, b, &(&1 + &2))
      |> Chrono.unwrap()
    assert c == 4600.0
  end

  test "add simple 1" do 
    a = Length.cm(120)
    b = Length.m(2)
    c = Length.plus(a, b) |> Length.unwrap
    assert c == 320.0
  end

  test "add simple 2" do 
    a = Length.cm(120)
    b = Length.m(2)
    c = Length.plus(b, a) |> Length.unwrap
    assert c == 3.2
  end

  test "sub simple 1" do 
    a = Length.cm(220)
    b = Length.m(2)
    c = Length.minus(a, b) |> Length.unwrap
    assert c == 20.0
  end

  test "sub simple 2" do 
    a = Length.cm(120)
    b = Length.m(2)
    c = Length.minus(b, a) |> Length.unwrap
    assert c == 0.8
  end

  test "mult simple 1" do 
    a = Chrono.min(200)
    b = Chrono.times(a, 3) |> Chrono.unwrap
    assert b == 600.0
  end

  test "div simple 1" do 
    a = Chrono.min(200)
    b = Chrono.div(a, 2) |> Chrono.unwrap
    assert b == 100.0
  end
  
  test "Simple normalization" do 
    a = Chrono.hour(1) |> Chrono.normalize()
    assert a == 3600.0
  end

  test "Comparison :eq 1" do 
    x = Length.m(1)
    y = Length.cm(100)
    assert (Length.compare(x, to: y)) == :eq
    assert (Length.compare(x, to: x)) == :eq
    assert (Length.compare(y, to: y)) == :eq
    assert (Length.compare(y, to: x)) == :eq
  end

  test "Comparison :lt/gt 1" do 
    x = Length.m(23)
    y = Length.cm(100)
    assert (Length.compare(x, to: y)) == :gt
    assert (Length.compare(y, to: x)) == :lt
  end

  test "Range.new 1" do 
    x = Length.cm(1)
    y = Length.m(1)
    r = Length.Range.new(x, y)
    assert r == {x, Length.cm(100)}
  end

  test "Increasing 1" do 
    x = Length.cm(1)
    y = Length.m(1)
    r = Length.Range.new(x, y)
    assert Length.Range.increasing?(r)
  end

  test "Increasing 2" do 
    x = Length.cm(1)
    y = Length.m(1)
    r = Length.Range.new(y, x)
    assert !Length.Range.increasing?(r)
  end
  
  
  


end
