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
  }


  @doc """
  Builds a range between two `typed_value`. if the two members 
  of the function are the same, the function will raise an 
  `ArgumentError`.

      iex> Mizur.Range.new!(MizurTest.Distance.cm(1), MizurTest.Distance.cm(10))
      {MizurTest.Distance.cm(1), MizurTest.Distance.cm(10)}

      iex> Mizur.Range.new!(MizurTest.Distance.m(1), MizurTest.Distance.cm(10))
      {MizurTest.Distance.m(1), MizurTest.Distance.m(10/100.0)}
  """
  @spec new!(Mizur.typed_value, Mizur.typed_value) :: range 
  def new!({type, _} = a, b) do 
    {a, Mizur.from(b, to: type)}
  end

  @doc """
  Checks if a `range` is increasing.

      iex> r = Mizur.Range.new!(MizurTest.Distance.cm(1), MizurTest.Distance.cm(10))
      ...> Mizur.Range.increasing?(r)
      true
  """
  @spec increasing?(range) :: boolean
  def increasing?({a, b}), do: Mizur.compare(a, with: b) in [:lt, :eq]


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
    {a, _} = sort(range)
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
  def first({a, _}), do: a 

  @doc """
  Returns the last element of a range.

      iex> a = MizurTest.Distance.cm(1000)
      ...> b = MizurTest.Distance.cm(2)
      ...> c = Mizur.Range.new!(a, b)
      ...> Mizur.Range.last(c)
      MizurTest.Distance.cm(2)
  """
  @spec last(range) :: Mizur.typed_value 
  def last({_, a}), do: a 

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
    {_, a} = sort(range)
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
  def type_of({{t, _}, _}), do: t 

  @doc """
  Sorts a range.

      iex> a = MizurTest.Distance.cm(1000)
      ...> b = MizurTest.Distance.cm(2)
      ...> c = Mizur.Range.new!(a, b)
      ...> Mizur.Range.sort(c)
      Mizur.Range.new!(MizurTest.Distance.cm(2), MizurTest.Distance.cm(1000))
  """
  @spec sort(range) :: range 
  def sort({a, b}) do 
    case Mizur.compare(a, with: b) do 
      :lt -> {a, b}
      _ -> {b, a}
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
  def reverse({a, b}), do: {b, a}

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
    {a, b} = sort(range)
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
    {startA, endA} = sort(a)
    {startB, endB} = sort(b)
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
  defp foldl_aux(acc, f, current, max, step, {next, flag}) do 
    cond do 
      Mizur.compare(current, with: max) == flag -> 
        new_acc = f.(acc, current)
        next_step = Mizur.map2(current, step, next)
        foldl_aux(new_acc, f, next_step, max, step, {next, flag})
      true -> f.(acc, max)
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
    data = if (increasing?(range)), do: {&+/2, :lt}, else: {&-/2, :gt}
    foldl_aux(default, f, first(range), last(range), real_step, data)
  end

  @doc """
  Folds (reduces) the given `range` from the left with a function. 
  Requires an accumulator.

      iex> a = MizurTest.Distance.cm(1)
      ...> b = MizurTest.Distance.cm(10)
      ...> r = Mizur.Range.new!(a, b)
      ...> Mizur.Range.foldr(r, fn(acc, x) -> [Mizur.unwrap(x) | acc] end, [])
      Enum.map((1..10), fn(x) -> x * 1.0 end)
  """
  @spec foldr(range, (Mizur.typed_value, any -> any), any, nil | Mizur.metric_type) :: any
  def foldr(range, f, default, step \\ nil) do 
    range 
    |> reverse()
    |> foldl(f, default, step)
  end

  @doc """
  Converts a range to a list of `typed_value`.

      iex> a = MizurTest.Distance.cm(1)
      ...> b = MizurTest.Distance.cm(10)
      ...> r = Mizur.Range.new!(a, b) 
      ...> Enum.map(Mizur.Range.to_list(r), &Mizur.unwrap/1)
      [1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0]
  """
  @spec to_list(range, nil | Mizur.metric_type) :: [Mizur.typed_value]
  def to_list(range, step \\ nil) do 
    range 
    |> foldr(fn(acc, x) -> [ x | acc ] end, [], step)
  end

  
end
