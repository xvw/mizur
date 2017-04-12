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

  test "new syntax" do 
    a = Length.m(1)
    b = Mizur.from(a, to: Length.mm)
    assert (Mizur.unwrap b) == 1000.0
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

  test "for fold" do 
    result = 
      [Length.cm(100), Length.km(1), Length.m(13)]
      |> Mizur.fold(
        Length.m(0), 
        fn(x, acc) -> 
          Mizur.map2(x, acc, fn(a, b) -> a+b end) 
        end,
        to: Length.m
        )
      |> Mizur.unwrap
      assert result == 1014.0

  end

  test "for Sum" do 
    result = 
      [Length.m(12), Length.km(1), Length.cm(14)]
      |> Mizur.sum(to: Length.cm)
      |> Mizur.unwrap()

    assert result == (100000 + 1200 + 14)*1.0
    
  end

  test "for comparison :eq 1" do 
    x = Length.m(1)
    y = Length.cm(100)
    assert (Mizur.compare(x, with: y)) == :eq
    assert (Mizur.compare(x, with: x)) == :eq
    assert (Mizur.compare(y, with: y)) == :eq
    assert (Mizur.compare(y, with: x)) == :eq
  end

  test "for comparison :lt/gt 1" do 
    x = Length.m(23)
    y = Length.cm(100)
    assert (Mizur.compare(x, with: y)) == :gt
    assert (Mizur.compare(y, with: x)) == :lt
  end

  test "failure of comparison" do 
    x = Length.m(23)
    y = Money.euro(100)
    assert_raise RuntimeError, "#{Length} is not compatible with #{Money}", fn -> 
      _ = Mizur.compare(y, with: x)
    end
  end

  test "for min" do 
    a = Length.cm(10000)
    b = Length.m(2)
    assert (Mizur.min(a, b)) == b
  end

  test "for max" do 
    a = Length.cm(10000)
    b = Length.m(2)
    assert (Mizur.max(a, b)) == a
  end

  test "for equals" do 
    a = Length.m(1)
    b = Length.cm(100)
    assert (Mizur.max(a, b)) == a
    assert (Mizur.min(a, b)) == a
  end
  
end
