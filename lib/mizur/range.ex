defmodule Mizur.Range do 

  @moduledoc """

  """

  @typedoc """
  This type represents a range of `typed_value`.
  """
  @type range :: {
    Mizur.typed_value, 
    Mizur.typed_value, 
    boolean # Min to max or Max to min
  }


  @doc """
  Builds a range between two `typed_value`. if the two members 
  of the function are the same, the function will raise an 
  `ArgumentError`.

      iex> Mizur.Range.new(MizurTest.Distance.cm(1), MizurTest.Distance.cm(10))
      {MizurTest.Distance.cm(1), MizurTest.Distance.cm(10), true}

      iex> Mizur.Range.new(MizurTest.Distance.m(1), MizurTest.Distance.cm(10))
      {MizurTest.Distance.m(1), MizurTest.Distance.cm(10), false}
  """
  @spec new(Mizur.typed_value, Mizur.typed_value) :: range 
  def new(a, b) do 
    ord =
      case Mizur.compare(a, with: b) do 
        :lt -> true 
        :gt -> false 
        :eq -> 
          raise ArgumentError, message: "Left and right are the same !"
      end
    {a, b, ord}
  end
  

end
