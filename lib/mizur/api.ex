defmodule Mizur.Api do 

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


    end

  end
  

end