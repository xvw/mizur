defmodule MizurTest do
  use ExUnit.Case
  doctest Mizur

  defmodule Length do 
    use Mizur
    type :cm
    type :dm = cm 10
    type :m  = dm 10
    type :km = m 1000
  end

  test "infix usage of from/2" do
    import Mizur
    elt = (Length.m(1) ~> Length.cm) |> unwrap
    assert elt == 100.0
  end
end
