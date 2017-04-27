defmodule Mizur.Range do 

  @moduledoc """
  This module provides a minimalistic approach of Range between 
  `typed_value`. A range is characterized by two values and a 
  direction. The two values must necessarily be different.
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
      {MizurTest.Distance.m(1), MizurTest.Distance.m(10/100.0), false}
  """
  @spec new!(Mizur.typed_value, Mizur.typed_value) :: range 
  def new!({type, _} = a, b) do 
    ord =
      case Mizur.compare(a, with: b) do 
        :lt -> true 
        :gt -> false 
        :eq -> 
          raise ArgumentError, message: "Left and right are the same !"
      end
    {a, Mizur.from(b, to: type), ord}
  end

  @doc """
  Checks if a `range` is increasing.

      iex> r = Mizur.Range.new!(MizurTest.Distance.cm(1), MizurTest.Distance.cm(10))
      ...> Mizur.Range.increasing?(r)
      true
  """
  @spec increasing?(range) :: boolean
  def increasing?({_, _, f}), do: f


  @doc """
  Checks if a `range` is decreasing.

      iex> r = Mizur.Range.new!(MizurTest.Distance.cm(10), MizurTest.Distance.cm(1))
      ...> Mizur.Range.decreasing?(r)
      true
  """
  @spec decreasing?(range) :: boolean
  def decreasing?(range), do: (not increasing?(range))

  @doc """
  Returns the smallest `typed_value` of a `range`.

      iex> a = MizurTest.Distance.cm(1000)
      ...> b = MizurTest.Distance.cm(2)
      ...> c = Mizur.Range.new!(a, b)
      ...> Mizur.Range.min(c)
      MizurTest.Distance.cm(2)
  """
  @spec min(range) :: Mizur.typed_value 
  def min(range) do 
    {a, _, _} = sort(range)
    a
  end

  @doc """
  Returns the first element of a range.

      iex> a = MizurTest.Distance.cm(1000)
      ...> b = MizurTest.Distance.cm(2)
      ...> c = Mizur.Range.new!(a, b)
      ...> Mizur.Range.first(c)
      MizurTest.Distance.cm(1000)
  """
  @spec first(range) :: Mizur.typed_value 
  def first({a, _, _}), do: a 

  @doc """
  Returns the last element of a range.

      iex> a = MizurTest.Distance.cm(1000)
      ...> b = MizurTest.Distance.cm(2)
      ...> c = Mizur.Range.new!(a, b)
      ...> Mizur.Range.last(c)
      MizurTest.Distance.cm(2)
  """
  @spec last(range) :: Mizur.typed_value 
  def last({_, a, _}), do: a 

  @doc """
  Returns the the biggest `typed_value` of a `range`.

      iex> a = MizurTest.Distance.cm(1000)
      ...> b = MizurTest.Distance.cm(2)
      ...> c = Mizur.Range.new!(a, b)
      ...> Mizur.Range.max(c)
      MizurTest.Distance.cm(1000)
  """
  @spec max(range) :: Mizur.typed_value 
  def max(range) do 
    {_, a, _} = sort(range)
    a
  end

  @doc """
  Returns the type of a `range`.

      iex> a = MizurTest.Distance.cm(1000)
      ...> b = MizurTest.Distance.km(2)
      ...> c = Mizur.Range.new!(a, b)
      ...> Mizur.Range.type_of(c)
      MizurTest.Distance.cm()
  """
  @spec type_of(range) :: Mizur.metric_type
  def type_of({{t, _}, _, _}), do: t 

  @doc """
  Sorts a range.

      iex> a = MizurTest.Distance.cm(1000)
      ...> b = MizurTest.Distance.cm(2)
      ...> c = Mizur.Range.new!(a, b)
      ...> Mizur.Range.sort(c)
      Mizur.Range.new!(MizurTest.Distance.cm(2), MizurTest.Distance.cm(1000))
  """
  @spec sort(range) :: range 
  def sort({a, b, ord} = range) do 
    cond do 
      ord -> range 
      true -> {b, a, true}
    end
  end

  @doc """
  Reverses a `range` : 

      iex> a = MizurTest.Distance.cm(1000)
      ...> b = MizurTest.Distance.cm(2)
      ...> c = Mizur.Range.new!(a, b)
      ...> Mizur.Range.reverse(c)
      Mizur.Range.new!(MizurTest.Distance.cm(2), MizurTest.Distance.cm(1000))
  """
  @spec reverse(range) :: range 
  def reverse({a, b, c}), do: {b, a, !c}

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

      iex> a = MizurTest.Distance.m(1)
      ...> b = MizurTest.Distance.km(1)
      ...> x = MizurTest.Distance.m(20)
      ...> y = MizurTest.Distance.km(2)
      ...> r = Mizur.Range.new!(a, b)
      ...> p = Mizur.Range.new!(x, y)
      ...> Mizur.Range.overlap?(r, p)
      true

      iex> a = MizurTest.Distance.m(1)
      ...> b = MizurTest.Distance.km(1)
      ...> x = MizurTest.Distance.km(2)
      ...> y = MizurTest.Distance.km(20)
      ...> r = Mizur.Range.new!(a, b)
      ...> p = Mizur.Range.new!(x, y)
      ...> Mizur.Range.overlap?(r, p)
      false

  """
  @spec overlap?(range, range) :: boolean 
  def overlap?(a, b) do 
    use Mizur.Infix, only: [>=: 2, <=: 2]
    {startA, endA, _} = sort(a)
    {startB, endB, _} = sort(b)
    (startA <= endB) and (endA >= startB) 
  end

  @doc """
  Tests if a range is a subrange of another range.

      iex> a = MizurTest.Distance.m(1)
      ...> b = MizurTest.Distance.km(1)
      ...> r = Mizur.Range.new!(a, b)
      ...> x = MizurTest.Distance.m(2)
      ...> y = MizurTest.Distance.m(900)
      ...> q = Mizur.Range.new!(x, y)
      ...> Mizur.Range.subrange?(q, of: r)
      true
  """
  @spec subrange?(range, [of: range]) :: boolean 
  def subrange?(a, of: b) do 
    {x, y} = {min(a), max(a)}
    include?(x, in: b) and include?(y, in: b)
  end

  @doc false
  defp foldl_aux(acc, f, current, max, step, next) do 
    case Mizur.compare(current, with: max) do 
      :lt -> 
        new_acc = f.(acc, current)
        next_step = Mizur.map2(current, step, next)
        foldl_aux(new_acc, f, next_step, max, step, next)
      _   -> f.(acc, max)
    end
  end

  @doc """
  Folds (reduces) the given `range` from the left with a function. 
  Requires an accumulator.

      iex> a = MizurTest.Distance.cm(1)
      ...> b = MizurTest.Distance.cm(10)
      ...> r = Mizur.Range.new!(a, b)
      ...> Mizur.Range.foldl(r, fn(acc, x) -> [Mizur.unwrap(x) | acc] end, [])
      Enum.map((10..1), fn(x) -> x * 1.0 end)

      iex> a = MizurTest.Distance.m(0)
      ...> b = MizurTest.Distance.m(10_000)
      ...> r = Mizur.Range.new!(a, b)
      ...> Mizur.Range.foldl(r, fn(acc, x) -> [Mizur.unwrap(x) | acc] end, [], MizurTest.Distance.km(1))
      Enum.map((10..0), fn(x) -> x * 1000.0 end)
  """
  @spec foldl(range, (Mizur.typed_value, any -> any), any, nil | Mizur.metric_type) :: any
  def foldl(range, f, default, step \\ nil) do 
    real_step = case step do 
      nil -> 
        {mod, t, _, _, _} = type_of(range)
        apply(mod, t, [1])
      data -> data
    end 
    next = if (increasing?(range)), do: &+/2, else: &-/2
    foldl_aux(default, f, first(range), last(range), real_step, next)
  end
  
end
