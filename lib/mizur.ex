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


  @doc false
  defmacro define_basis(basis) do 
    quote do 
      @basis unquote(basis)
      @metrics [unquote(basis) | @metrics]

      def unquote(basis)() do 
        {
          __MODULE__, 
          unquote(basis),
          fn(x) -> x * 1.0 end, 
          fn(x) -> x * 1.0 end
        }
      end

      def unquote(basis)(value) do 
        {
          apply(__MODULE__, unquote(basis), []),
          value * 1.0
        }
      end
      
    end
  end


  @doc false
  defmacro define_internal_type(name, expr) do 
    quote do 
      @metrics [unquote(name) | @metrics]
    end
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

  @doc false
  defmacro type({:=, _, [{name, _, nil}, rest]}) do 
    quote do 
      case @basis do 
        nil -> 
          raise RuntimeError, 
            message: "Basis must be defined"
        _ -> 
          cond do 
            Enum.member?(@metrics, unquote(name)) ->
              raise RuntimeError, 
                message: "#{unquote(name)} is already defined"
            true -> define_internal_type(unquote(name), unquote(rest))
              
          end
      end
    end
  end
  

  @doc false
  defmacro type(value) do 
    raise RuntimeError, 
      message: "The line is unparsable"
  end

  def unwrap({_, value}), do: value

end
