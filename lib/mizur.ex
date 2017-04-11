defmodule Mizur do

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
          @operators, unquote(name), unquote(value) * 1.0
        )
      )
      def unquote(name)() do
        {__MODULE__, unquote(name), unquote(value) * 1.0}
      end
      def unquote(name)(to_be_typed) do 
        {apply(__MODULE__, unquote(name), []), to_be_typed * 1.0}
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
                Map.get(@operators, unquote(basis)) 
                * unquote(coeff)
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


end
