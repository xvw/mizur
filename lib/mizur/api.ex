defmodule Mizur.Api do
  @moduledoc false

  defmacro __using__(_opts) do
    quote do
      import Mizur.Api

      @typedoc """
      This type represents a results of a comparison
      """
      @type comparison_result :: :eq | :lt | :gt

      @doc """
      Extracts the value of a `typed_value`.
      """
      @spec unwrap(t) :: float
      def unwrap(%__MODULE__{} = t), do: t.value

      @doc """
      Unwraps the value, coerced as a base.
      """
      @spec normalize(t) :: float
      def normalize(%__MODULE__{} = t) do
        t.type.to_basis.(t.value)
      end

      @doc """
      same as `#{__MODULE__}.unwrap/2`
      """
      @spec to_float(t, integer) :: float
      def to_float(%__MODULE__{} = t, precision \\ 0), do: Float.round(t.value, precision)

      @doc """
      Extracts the value into an integer
      """
      @spec to_integer(t) :: integer
      def to_integer(%__MODULE__{} = t), do: round(t.value)

      @doc """
      Converts a `typed_value` to another subtype of its measure system.
      """
      @spec from(t, to: subtype) :: t
      def from(%__MODULE__{} = basis, to: %__MODULE__.Type{} = target) do
        from = target.from_basis
        to = basis.type.to_basis
        value = basis.value
        %__MODULE__{type: target, value: from.(to.(value))}
      end

      @doc """
      Applies a function to the numeric value of a `typed_value` and re-packs
      the result of the function in the same subtype.
      """
      @spec map(t, (number -> number)) :: t
      def map(%__MODULE__{} = t, f) do
        %{t | value: f.(t.value)}
      end

      @doc """
      Applies a function to the two numeric values of two `typed_values` in
      the same measure system, and re-packages the result
      of the function in a `typed_value` of the subtype of the left
      `typed_values`.
      """
      @spec map2(t, t, (number, number -> number)) :: t
      def map2(%__MODULE__{} = a, %__MODULE{} = b, f) do
        x = from(b, to: a.type)
        %{a | value: f.(a.value, x.value)}
      end

      @doc """
      Makes the addition between two `typed_value` of the same measure system.
      The return value will have the subtype of the left `typed_value`.
      """
      @spec plus(t, t) :: t
      def plus(a, b) do
        map2(a, b, &(&1 + &2))
      end

      @doc """
      Makes the subtraction between two `typed_value` of the same measure system.
      The return value will have the subtype of the left `typed_value`.
      """
      @spec minus(t, t) :: t
      def minus(a, b) do
        map2(a, b, &(&1 - &2))
      end

      @doc """
      Multiplies a `typed_value` by a `number`. The subtype of the return value
      will be the subtype of the left `typed_value`.
      """
      @spec times(t, number) :: t
      def times(a, b) when is_number(b) do
        x = unwrap(a)
        %{a | value: x * b}
      end

      @doc """
      Divides a `typed_value` by a `number`. The subtype of the return value
      will be the subtype of the left `typed_value`.
      """
      @spec div(t, number) :: t
      def div(a, b) when is_number(b) do
        x = unwrap(a)
        %{a | value: x / b}
      end

      @doc """
      Comparison between two `typed_value` of the same measure system.
      The function returns:
      -  `:eq` for `equals`
      -  `:lt` if the left-values is **lower than** the right-values
      -  `:gt` if the left-values is **greater than** the right-values
      """
      @spec compare(t, to: t) :: comparison_result
      def compare(%__MODULE__{} = a, to: %__MODULE__{} = b) do
        left = normalize(a)
        right = normalize(b)

        cond do
          left > right -> :gt
          left < right -> :lt
          true -> :eq
        end
      end
    end
  end
end
