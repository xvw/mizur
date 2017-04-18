defmodule Mizur do

  @doc false
  defmacro __using__(_opts) do 
    quote do 
      import Mizur
      @basis nil
      @metrics []
      @before_compile Mizur
    end
  end

  @doc false
  defmacro __before_compile__(_env) do
    quote do
      def system_metric do
        @metrics
      end
    end
  end

  defmacro define_basis(basis) do 
    IO.inspect basis
  end

  
  @doc false
  defmacro type({basis, _, nil}) do
    quote do
      case @basis do 
        nil -> define_basis(unquote(basis))
        _ -> 
          raise RuntimeError, 
            message: "Basis is already defined (#{@basis})"
      end
    end
  end

  defmacro type(value) do 
    IO.inspect value
  end


end
