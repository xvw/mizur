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

      iex> Mizur.Range.new!(MizurTest.Distance.cm(1), MizurTest.Distance.cm(10))
      {MizurTest.Distance.cm(1), MizurTest.Distance.cm(10), true}

      iex> Mizur.Range.new!(MizurTest.Distance.m(1), MizurTest.Distance.cm(10))
      {MizurTest.Distance.m(1), MizurTest.Distance.cm(10), false}
  """
  @spec new!(Mizur.typed_value, Mizur.typed_value) :: range 
  def new!(a, b) do 
    ord =
      case Mizur.compare(a, with: b) do 
        :lt -> true 
        :gt -> false 
        :eq -> 
          raise ArgumentError, message: "Left and right are the same !"
      end
    {a, b, ord}
  end

  @doc """
  Sorts a range.

      iex> a = MizurTest.Distance.m(1)
      ...> b = MizurTest.Distance.cm(2)
      ...> c = Mizur.Range.new!(a, b)
      ...> Mizur.Range.sort(c)
      Mizur.Range.new!(MizurTest.Distance.cm(2), MizurTest.Distance.m(1))
  """
  @spec sort(range) :: range 
  def sort({a, b, ord} = range) do 
    cond do 
      ord -> range 
      true -> {b, a, true}
    end
  end

  @doc """
  Checks if a `typed_value` is included in a range.

      iex> a = MizurTest.Distance.cm(1)
      ...> b = MizurTest.Distance.km(10)
      ...> r = Mizur.Range.new!(a, b)
      ...> p = Mizur.Range.new!(b, a)
      ...> x = MizurTest.Distance.m(1987)
      ...> {Mizur.Range.include?(x, in: r), Mizur.Range.include?(x, in: p)}
      {true, true}
  """
  @spec include?(Mizur.typed_value, [in: range]) :: boolean
  def include?(value, in: range) do 
    use Mizur.Infix, only: [>=: 2, <=: 2]
    {a, b, _} = sort(range)
    (value >= a) and (value <= b)
  end


  @doc """
  Checks if two ranges overlap.

      iex> :to_be_done
      :to_be_done

  """
  @spec overlap?(range, range) :: boolean 
  def overlap?(a, b) do 
    use Mizur.Infix, only: [>=: 2, <=: 2]
    {startA, endA, _} = sort(a)
    {startB, endB, _} = sort(b)
    (startA <= endB) and (endA >= startB) 
  end
  
end
