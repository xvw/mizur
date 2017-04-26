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
  """
  @spec new(Mizur.typed_value, Mizur.typed_value) :: range 
  def new(a, b) do 
    ord =
      case Mizur.compare(a, b) do 
        :lt -> true 
        :gt -> false 
        :eq -> 
          raise ArgumentError, message: "Left and right are the same !"
      end
    {a, b, ord}
  end
  

end
