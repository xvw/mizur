defmodule Mizur do

  @doc false
  defmacro __using__(_opts) do 
    quote do 
      import Mizur
      @base nil
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
  defmacro define_basis(name) do 
    quote do
      case @base do 
        nil ->
          def unquote(name)() do 
            {__MODULE__, unquote(name), [
              fn(x) -> x * 1.0 end,
              fn(x) -> x * 1.0 end
            ]}
          end

          def unquote(name)(value) do 
            {apply(__MODULE__, unquote(name), []), value * 1.0}
          end
          
          @base unquote(name)
          @metrics [ unquote(name) | @metrics ]
        _ -> 
          log = "Basis is already defined: #{@base}"
          raise RuntimeError, message: log
      end
    end
  end

  def fail_at(nl, msg) do 
    module_line = "#{__MODULE__}:#{nl}"
    raise RuntimeError, message: "line #{module_line} #{msg}"
  end

  defmacro lambda(expr) do 
    quote do: (fn(x) -> unquote(expr) end)
  end
  

  @doc false 
  defmacro define_type(nl, name, f_expr) do
    quote do 
      cond do 
        Enum.member?(@metrics, unquote(name)) -> 
          fail_at(unquote(nl), "#{unquote(name)} already exists")
        true -> 
          @metrics [unquote(name) | @metrics ]
          def unquote(name)() do 
            {
              __MODULE__, 
              unquote(name), 
              lambda(unquote(f_expr)), 
              revert_lambda(unquote(f_expr))
            }
          end
      end
    end
  end
  

  @doc false
  defmacro type(value) do 
    IO.inspect value
    case value do 

      {:=, [line: nl], [{value, _, _}, expr]} ->
        quote do: define_type(unquote(nl), unquote(value), unquote(expr))

      {value, _, _} when is_atom(value) -> 
        quote do: define_basis(unquote(value))

      {_, [line: nl], _} -> fail_at(nl, "is not parsable")
        
    end
    
  end


end
