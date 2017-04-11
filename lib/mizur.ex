defmodule Mizur do

  @moduledoc """
  Mizur is a tool to simplify the handling of units.
  > Mizur is the new version of [Abacus](https://github.com/xvw/abacus)
  """

  @typedoc """
  This type represents a unit of measure (defined with using Abacus.SystemMetric)
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
          nquote(value) * 1.0
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


end
