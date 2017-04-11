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
  def map2({{module, _, _} = t, elt}, {{module, _, _}, _} = elt2, f) do 
    {t, f.(elt, unwrap(elt2 ~> t))}
  end

  
end
