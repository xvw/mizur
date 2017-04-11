defmodule MizurTest do
  use ExUnit.Case
  doctest Mizur

  defmodule Test do 
    use Mizur
    type :cm
    type :m  = cm 100
    type :km = m 1000
  end

  test "the truth" do
    IO.inspect Test.system_metric
    IO.inspect Test.km(12)
    assert 1 + 1 == 2
  end
end
