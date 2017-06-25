defmodule Mizur.Api do 

  @moduledoc """
  Provide the "high level API" for a Mizur Strucutre.
  """

  defmacro __using__(_opts) do 
    quote do 
      import Mizur.Api 

      @doc """
      Extract the value of a **typed_value**
      """
      @spec unwrap(t) :: float
      def unwrap(%__MODULE__{} = t), do: t.value

      @doc """
      same of `#{__MODULE__}.unwrap/2`
      """
      @spec to_float(t) :: float
      def to_float(%__MODULE__{} = t), do: t.value

      @doc """
      Extract the value into an integer
      """
      @spec to_integer(t) :: integer
      def to_integer(%__MODULE__{} = t), do: round(t.value)

      @doc """
      Converts a `typed_value` to another subtype of its metric system.
      """
      @spec from(t, [to: subtype]) :: t
      def from(%__MODULE__{} = basis, to: %__MODULE__.Type{} = target) do 
        from = target.from_basis
        to = basis.type.to_basis
        value = basis.value
        %__MODULE__{ type: target, value: from.(to.(value))}
      end

      @doc """
      Applies a function to the numeric value of a `typed_value` and re-packs
      the result of the function in the same subtype.
      """
      @spec map(t, (number -> number)) :: t
      def map(%__MODULE__{} = t, f) do 
        %{ t | value: f.(t.value) }
      end

      @doc """
      Applies a function to the two numeric values of two `typed_values` in
      the same metric system, and re-packages the result 
      of the function in a `typed_value` of the subtype of the left 
      `typed_values`.
      """
      @spec map2(t, t, (number, number -> number)) ::  t
      def map2(%__MODULE__{} = a, %__MODULE{} = b, f) do 
        x = from(b, to: a.type)
        %{ a | value: f.(a.value, x.value)}
      end

      @spec add(t, t) :: t 
      def add(a, b) do 
        map2(a, b, &(&1 + &2))
      end

      @spec sub(t, t) :: t 
      def sub(a, b) do 
        map2(a, b, &(&1 - &2))
      end

      @spec mult(t, number) :: t 
      def mult(a, b) when is_number(b) do 
        x = unwrap(a)
        %{ a | value: (x * b)}
      end

      @spec div(t, number) :: t 
      def div(a, b) when is_number(b) do 
        x = unwrap(a)
        %{ a | value: (x / b)}
      end
      
       
    end

  end
  

end