defmodule MizurTest do
  use ExUnit.Case
  doctest Mizur

  defmodule Length do 
    use Mizur
    type :cm
    type :m  = cm 100
    type :km = m 1000
  end

  test "the truth" do
    import Mizur
    elt = (Length.m(1) ~> Length.cm) |> unwrap
    assert elt == 100.0
  end
end
