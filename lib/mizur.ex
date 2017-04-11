defmodule Mizur do

  @moduledoc """
  Mizur is a tool to simplify the handling of units.
  > Mizur is the new version of [Abacus](https://github.com/xvw/abacus)
  """

  @typedoc """
  This type represents a unit of measure (defined with using Mizur)
  """
  @type metric_type :: { module, atom, number}

  @typedoc """
  This type represents a value wrapped in a metric system
  """
  @type typed_value :: { metric_type, float }

  @typedoc """
  This type represents a results of a comparison
  """
  @type comparison  :: :eq | :lt | :gt

  @doc false
  defmacro __using__(_opts) do 
    quote do 
      import Mizur
      @base nil
      @operators %{}
      @before_compile Mizur
    end
  end

  @doc false
  defmacro __before_compile__(_env) do
    quote do
      def system_metric do
        @operators
      end
    end
  end

  @doc false
  defmacro define_internal_type(name, value) do 
    quote do 
      @operators (
        Map.put_new(
          @operators, 
          unquote(name), 
          unquote(value) * 1.0
        )
      )
      def unquote(name)() do
        {
          __MODULE__, 
          unquote(name), 
          unquote(value) * 1.0
        }
      end
      def unquote(name)(to_be_typed) do 
        {
          apply(__MODULE__, unquote(name), []), 
          to_be_typed * 1.0
        }
      end
    end
  end

  @doc false
  defmacro type(value) do
    case value do 
      {:=, _, [name, {basis, _, [coeff]}]} -> 
        quote do
          case Map.has_key?(@operators, unquote(basis)) do 
            false -> 
              raise RuntimeError, 
                message: "#{unquote(basis)} is not defined in #{__MODULE__}"
            _ -> 
              define_internal_type(
                unquote(name), 
                Map.get(@operators, 
                unquote(basis)) * unquote(coeff)
              )
          end
        end
      value when is_atom(value) ->
        quote do  
          case @base do      
            nil->
              @base unquote(value)
              define_internal_type(unquote(value), 1.0)
            _ -> 
              base_msg = "Base(#{@base})"
              raise RuntimeError, 
                message: "#{base_msg} is already defined for #{__MODULE__}"
            end
          end
      {_, [line: nl], _} -> 
        module_line = "#{__MODULE__}:#{nl}"
        raise RuntimeError, 
          message: "line #{module_line} is not parsable"
    end

  end

  @doc """
  Retrieves the wrapped numeric value in a `typed_value()`.
  For example: 
      iex> x = MizurTest.Length.cm(12)
      ...> Mizur.unwrap(x)
      12.0
  """
  @spec unwrap(typed_value) :: float
  def unwrap({_, value}), do: value

 @doc """
 Converts a `typed_value()` to another subtype of its metric system.

 For example: 
      iex> x = MizurTest.Length.cm(120)
      ...> Mizur.from(x, to: MizurTest.Length.m)
      {MizurTest.Length.m, 1.2}
  """
  @spec from(typed_value, [to: metric_type]) :: typed_value
  def from({{module, _, coeff}, elt}, to: {module, _, coeff_basis} = basis) do 
    divider = 1 / coeff_basis
    basis_elt = (elt * coeff) * divider
    {basis, basis_elt}
  end
  def from({{module, _, _}, _}, to: {other_module, _, _}) do 
    message = "#{module} is not compatible with #{other_module}"
    raise RuntimeError, message: message
  end
  

  @doc """
  Converts a `typed_value()` to another subtype of its metric system.
  An infix version for `from/2`

  For example:
      iex> import Mizur
      ...> MizurTest.Length.m(1) ~> MizurTest.Length.cm
      {MizurTest.Length.cm, 100.0}
  """
  @spec typed_value ~> metric_type :: typed_value
  def elt ~> output_type do 
    from(elt, to: output_type)
  end

  @doc """
  Applies a function to the numeric value of a typed value and re-packs
  the result of the function in the same subtype.
  For example:
      iex> MizurTest.Length.km(120)
      ...> |> Mizur.map(fn(x) -> x * 2 end)
      {MizurTest.Length.km, 240.0}
  """
  @spec map(typed_value, (float -> float)) :: typed_value
  def map({type, elt}, f), do: {type, f.(elt)}

  @doc """
  Applies a function to the two numeric values of two `typed_values()` in 
  the same metric system, and re-packages the result 
  of the function in a `typed_value()` of the subtype of the left `typed_values()`.
  For example: 
      iex> a = MizurTest.Length.m(100)
      ...> b = MizurTest.Length.cm(200)
      ...> Mizur.map2(a, b, &(&1 * &2))
      {MizurTest.Length.m, 200.0}
  """
  @spec map2(typed_value, typed_value, (float, float -> float)) :: typed_value
  def map2({t, elt}, elt2, f) do 
    {t, f.(elt, unwrap(elt2 ~> t))}
  end

  @doc """
  `List.foldl` for a list of `typed_value()` from the same metric system.

  For example:
      iex> 
      ...> Mizur.fold(
      ...>   [ MizurTest.Length.cm(10),  MizurTest.Length.dm(1),  MizurTest.Length.m(12)], 
      ...>   MizurTest.Length.cm(12),
      ...>   fn(x, acc) -> Mizur.map2(x, acc, &(&1+&2)) end,
      ...>   to:  MizurTest.Length.cm
      ...>)
      {MizurTest.Length.cm, 1232.0}
  """
  @spec fold([typed_value], any, ((typed_value, any) -> any), [to: metric_type]) :: typed_value
  def fold(list, default, f, to: basis) do 
    List.foldl(list, default, fn(elt, acc) ->
      f.(elt ~> basis, acc)
    end)
  end

  @doc """
  Calculates the sum of a list of `typed_value()` of the same 
  metric system, projected into a specific subtype.
  For example: 
      iex> Mizur.sum(
      ...>   [
      ...>       MizurTest.Length.cm(10), 
      ...>       MizurTest.Length.dm(1), 
      ...>       MizurTest.Length.m(12)
      ...>   ], 
      ...>   to: MizurTest.Length.dm
      ...> )
      {MizurTest.Length.dm, 122.0}
  """
  @spec sum([typed_value], [to: metric_type]) :: typed_value
  def sum(list, to: {module, basis_name, _coeff} = basis) do 
    fold(
      list, apply(module, basis_name, [0]),
      &add/2,
      to: basis
    )
  end


  @doc """
  Comparison between two `typed_value()` of the same metric system.
  The function returns:
  -  `:eq` for `equals` 
  -  `:lt` if the left-values is **lower than** the right-values
  -  `:gt` if the left-values is **greater than** the right-values
  For example:
      iex> x = MizurTest.Length.m(1)
      ...> y = MizurTest.Length.cm(100)
      ...> Mizur.compare(x, with: y)
      :eq
  """
  @spec compare(typed_value, [with: typed_value]) :: comparison
  def compare({t, _} = left, with: right) do 
    a = unwrap(left)
    b = unwrap(from(right, to: t))
    cond do 
      a > b -> :gt 
      b > a -> :lt
      true  -> :eq
    end
  end

  @doc """
  Makes the addition between two `typed_value()` of the same metric system. 
  The return value will have the subtype of the left `typed_value()`.
      iex> a = MizurTest.Length.cm(12)
      ...> b = MizurTest.Length.m(2)
      ...> Mizur.add(a, b)
      {MizurTest.Length.cm, 212.0}
  """
  @spec add(typed_value, typed_value) :: typed_value
  def add(a, b) do 
    map2(a, b, &(&1 + &2))
  end


  @doc """
  Makes the subtraction between two `typed_value()` of the same metric system. 
  The return value will have the subtype of the left `typed_value()`.
      iex> a = MizurTest.Length.cm(12)
      ...> b = MizurTest.Length.m(2)
      ...> Mizur.sub(b, a)
      {MizurTest.Length.m, 1.88}
  """
  @spec sub(typed_value, typed_value) :: typed_value
  def sub(a, b) do 
    map2(a, b, &(&1 - &2))
  end

  @doc """
  Multiplies a `typed_value()` by a `number()`. The subtype of the return value 
  will be the subtype of the left `typed_value()`.
      iex> a = MizurTest.Length.cm(12)
      ...> Mizur.mult(a, 10)
      {MizurTest.Length.cm, 120.0}
  """
  @spec mult(typed_value, number) :: typed_value
  def mult(a, b) do 
    map(a, fn(x) -> x * b end)
  end

  @doc """
  Divides a `typed_value()` by a `number()`. The subtype of the return value 
  will be the subtype of the left `typed_value()`.
      iex> a = MizurTest.Length.cm(12)
      ...> Mizur.div(a, 2)
      {MizurTest.Length.cm, 6.0}
  """
  @spec div(typed_value, number) :: typed_value
  def div(a, b) do 
    mult(a, 1/b)
  end

end
