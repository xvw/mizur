defmodule Mizur do

  @moduledoc """
  **Mizur** is a tool to simplify the management, conversions  
  and mapping of units. 

  The manipulation of units of measurement try (at best) 
  to be typesafe.
  """


  @typedoc """
  This type represents a unit of measure 
  (defined with using Mizur.System)
  """
  @type metric_type :: {
    module, 
    atom, 
    boolean, 
    (number -> float),
    (number -> float)
  }

  @typedoc """
  This type represents a value wrapped in a metric system
  """
  @type typed_value :: {
    metric_type, 
    float
  }

  @typedoc """
  This type represents a results of a comparison
  """
  @type comparison_result :: :eq | :lt | :gt


  @doc """
  Retrieves the wrapped numeric value in a `typed_value`.

  For example: 
      iex> x = MizurTest.Distance.cm(12)
      ...> Mizur.unwrap(x)
      12.0
  """
  @spec unwrap(typed_value) :: float
  def unwrap({_, value}), do: value

  @doc """
  Retrieves the type of a `typed_value`.

  For example: 
      iex> x = MizurTest.Distance.cm(12)
      ...> Mizur.type_of(x)
      MizurTest.Distance.cm
  """
  @spec type_of(typed_value) :: metric_type
  def type_of({t, _}), do: t

  @doc """
  Retrieves the system of a `typed_value`.

  For example: 
      iex> x = MizurTest.Distance.cm(12)
      ...> Mizur.system_of(x)
      MizurTest.Distance
  """
  @spec system_of(typed_value) :: module
  def system_of({{m, _, _, _, _}, _}), do: m


  @doc """
  Reformulation of `Mizur.in_type/2`

  For example: 
      iex> x = MizurTest.Distance.cm(12)
      ...> Mizur.in?(x, type: MizurTest.Distance.cm)
      true
  """
  def in?(value, type: t), do: in_type?(value, t)

  @doc """
  Reformulation of `Mizur.in_system/2`

  For example: 
      iex> x = MizurTest.Distance.cm(12)
      ...> Mizur.in?(x, system: MizurTest.Temperature)
      false
  """
  def in?(value, system: s), do: in_system?(value, s)


  @doc """
  Checks if a `typed_value` is included in a `metric_type`.

  For example: 
      iex> x = MizurTest.Distance.cm(12)
      ...> Mizur.in_type?(x, MizurTest.Distance.cm)
      true
  """
  @spec in_type?(typed_value, metric_type) :: boolean
  def in_type?({t, _}, t), do: true 
  def in_type?(_, _), do: false

  @doc """
  Checks if a `typed_value` is included in a system.

  For example: 
      iex> x = MizurTest.Distance.cm(12)
      ...> Mizur.in_system?(x, MizurTest.Distance)
      true
  """
  @spec in_system?(typed_value, module) :: boolean 
  def in_system?({{m, _, _, _, _}, _}, m), do: true 
  def in_system?(_, _), do: false

  @doc """
  Checks if two `typed_value` has the same type.

  For example: 
      iex> x = MizurTest.Distance.cm(12)
      ...> y = MizurTest.Distance.cm(100)
      ...> Mizur.same_type?(x, y)
      true
  """
  @spec same_type?(typed_value, typed_value) :: boolean 
  def same_type?({t, _}, {t, _}), do: true
  def same_type?(_, _), do: false

  @doc """
  Checks if two `typed_value` has the same system.

  For example: 
      iex> x = MizurTest.Distance.cm(12)
      ...> y = MizurTest.Distance.km(100)
      ...> Mizur.same_system?(x, y)
      true
  """
  @spec same_system?(typed_value, typed_value) :: boolean 
  def same_system?({{m, _, _, _, _}, _}, {{m, _, _, _, _}, _}), do: true
  def same_system?(_, _), do: false
 


  @doc """
  Converts a `typed_value` to another subtype of its metric system.

  For example: 
      iex> x = MizurTest.Distance.cm(120)
      ...> Mizur.from(x, to: MizurTest.Distance.m)
      {MizurTest.Distance.m, 1.2}
  """
  @spec from(typed_value, [to: metric_type]) :: typed_value
  def from({{module, _, _, _, to}, base}, to: {module, _, _, from, _} = t) do
    new_value = from.(to.(base))
    {t, new_value}
  end

  def from({{m, _, _, _, _},_}, to: {other_m, _, _, _, _}) do 
    message = "#{m} is not compatible with #{other_m}"
    raise RuntimeError, message: message
  end


  @doc """
  Applies a function to the numeric value of a `typed_value` and re-packs
  the result of the function in the same subtype.
  
  For example:
      iex> MizurTest.Distance.km(120)
      ...> |> Mizur.map(fn(x) -> x * 2 end)
      {MizurTest.Distance.km, 240.0}
  """
  @spec map(typed_value, (number -> number)) :: typed_value 
  def map({type, elt}, f) do 
    {type, f.(elt)}
  end

  @doc """
  Applies a function to the two numeric values of two `typed_values` in 
  the same metric system, and re-packages the result 
  of the function in a `typed_value` of the subtype of the left `typed_values`.
  
  For example: 
      iex> a = MizurTest.Distance.m(100)
      ...> b = MizurTest.Distance.km(2)
      ...> Mizur.map2(a, b, &(&1 * &2))
      {MizurTest.Distance.m, 200000.0}
  """
  @spec map2(typed_value, typed_value, (number, number -> number)) :: typed_value
  def map2({t, a}, elt2, f) do 
    {_, b } = from(elt2, to: t)
    {t, f.(a, b)}
  end


  @doc """
  Comparison between two `typed_value` of the same metric system.

  The function returns:
  -  `:eq` for `equals` 
  -  `:lt` if the left-values is **lower than** the right-values
  -  `:gt` if the left-values is **greater than** the right-values

  For example:
      iex> x = MizurTest.Distance.m(1)
      ...> y = MizurTest.Distance.cm(100)
      ...> Mizur.compare(x, with: y)
      :eq
  """
  @spec compare(typed_value, [with: typed_value]) :: comparison_result
  def compare({t, left}, with: elt_right) do 
    {_, right} = from(elt_right, to: t)
    cond do 
      left > right -> :gt 
      right > left -> :lt 
      true         -> :eq 
    end
  end

  @doc """
  Returns `true` if two `yped_values` ​​have the same numeric 
  value (in the same metric system). `false` otherwise.

      iex> a = MizurTest.Distance.cm(100)
      ...> b = MizurTest.Distance.m(1)
      ...> c = MizurTest.Temperature.celsius(1)
      ...> {Mizur.equals(a, b), Mizur.equals(b, c)}
      {true, false}
  """
  @spec equals(typed_value, typed_value) :: boolean 
  def equals(a, b) do
    same_system?(a, b) && compare(a, with: b) == :eq
  end

  @doc """
  Returns `true` if two `yped_values` ​​have the same numeric 
  value (in the same type). `false` otherwise.

      iex> a = MizurTest.Distance.cm(100)
      ...> b = MizurTest.Distance.cm(100)
      ...> c = MizurTest.Distance.m(1)
      ...> {Mizur.strict_equals(a, b), Mizur.strict_equals(b, c)}
      {true, false}
  """
  @spec strict_equals(typed_value, typed_value) :: boolean
  def strict_equals(a, b) do 
    same_type?(a, b) && compare(a, with: b) == :eq
  end
  

  @doc false
  defp fail_for_intensive() do 
    raise RuntimeError, 
      message: "Arithmetic operations are not allowed for extensive system"
  end

  @doc """
  Makes the addition between two `typed_value` of the same metric system. 
  The return value will have the subtype of the left `typed_value`.

  **Warning:** Arithmetic operations are not allowed for extensive system

      iex> a = MizurTest.Distance.cm(12)
      ...> b = MizurTest.Distance.m(2)
      ...> Mizur.add(a, b)
      MizurTest.Distance.cm(212)
  """
  @spec add(typed_value, typed_value) :: typed_value 
  def add({{_, _, false, _, _}, _} = a, b) do 
    map2(a, b, &+/2)
  end
  def add(_, _), do: fail_for_intensive()
  

  @doc """
  Makes the subtraction between two `typed_value` of the same metric system. 
  The return value will have the subtype of the left `typed_value`.

  **Warning:** Arithmetic operations are not allowed for extensive system

      iex> a = MizurTest.Distance.cm(12)
      ...> b = MizurTest.Distance.m(2)
      ...> Mizur.sub(b, a)
      MizurTest.Distance.m(1.88)
  """
  @spec sub(typed_value, typed_value) :: typed_value 
  def sub({{_, _, false, _, _}, _} = a, b) do 
    map2(a, b, &-/2)
  end
  def sub(_, _), do: fail_for_intensive()

  @doc """
  Multiplies a `typed_value` by a `number`. The subtype of the return value 
  will be the subtype of the left `typed_value`.

  **Warning:** Arithmetic operations are not allowed for extensive system

      iex> a = MizurTest.Distance.cm(12)
      ...> Mizur.mult(a, 100)
      MizurTest.Distance.cm(1200)
  """
  @spec mult(typed_value, number) :: typed_value 
  def mult({{_, _, false, _, _}, _} = a, b) do 
    map(a, &(&1*b))
  end
  def mult(_, _), do: fail_for_intensive()

  @doc """
  Divides a `typed_value` by a `number`. The subtype of the return value 
  will be the subtype of the left `typed_value`.

  **Warning:** Arithmetic operations are not allowed for extensive system

      iex> a = MizurTest.Distance.cm(12)
      ...> Mizur.div(a, 2)
      MizurTest.Distance.cm(6.0)
  """
  @spec div(typed_value, number) :: typed_value 
  def div({{_, _, false, _, _}, _} = a, b) do 
    map(a, &(&1/b))
  end
  def div(_, _), do: fail_for_intensive()
  
end
