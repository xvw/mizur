defmodule MizurTest do
  use ExUnit.Case
  doctest Mizur

  defmodule Length do 
    use Mizur
    type :cm
    type :mm = cm 1/10
    type :dm = cm 10
    type :m  = dm 10
    type :km = m 1000
  end

  defmodule Money do 
    use Mizur
    type :euro
    type :dollar = euro 1.06665
  end

  
  test "for unwraping" do 
    input = Length.cm(12)
    assert (Mizur.unwrap input) == 12.0
  end

  test "infix usage of from/2" do
    import Mizur
    elt = (Length.m(1) ~> Length.cm) 
    |> unwrap
    assert elt == 100.0
  end

  test "for difftyped data" do 
    k = Money.euro(12)
    module = Money
    other_module = Length
    assert_raise RuntimeError, "#{module} is not compatible with #{other_module}", 
    fn -> _ = Mizur.from(k, to: Length.cm) end
  end

  test "for conversion" do 
    input = Length.cm(350)
    to_m  = Mizur.from input, to: Length.m
    assert Mizur.unwrap(to_m) == 3.5
  end

  test "for Mapping" do 
    input = Length.cm(12)
    |> Mizur.map(fn(x) -> x + 10 end)
    |> Mizur.unwrap
    assert input == 22.0
  end

  test "for map2" do 
    a = Length.dm(12)
    b = Length.dm(34)
    c = Mizur.map2(a, b, fn(x, y) -> x + y end)
    assert Mizur.unwrap(c) == 46
  end 

  test "failure for map2" do 
    a = Money.euro(12)
    b = Length.dm(34)
    assert_raise RuntimeError, "#{Length} is not compatible with #{Money}", 
    fn ->  _ = Mizur.map2(a, b, fn(x, y) -> x + y end) end
  end


end
