defmodule Mizur do


  defmodule System do 

    @doc false
    defmacro __using__(_opts) do 
      quote do 
        import Mizur.System
        @basis nil
        @metrics []
        @before_compile Mizur.System
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
    def revert_expr(acc, expr) do 
      IO.inspect expr
      case expr do 
        {_, _, nil} -> acc
        _ -> acc
      end
    end


    @doc false 
    defmacro create_lambda(expr) do 
      formatted = Macro.postwalk(expr, fn(elt) -> 
        case elt do 
          {x, _, nil} when is_atom(x) -> {:basis, [], __MODULE__}
          _ -> elt
        end
      end)
      quote do: (fn(basis) -> unquote(formatted) end)
    end

    @doc false 
    defmacro revert_lambda(expr) do 
      formatted = revert_expr({:target, [], __MODULE__}, expr)
      quote do: (fn(target) -> unquote(formatted) end)
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
            fn(x) -> x * 1.0 end, # to_basis
            fn(x) -> x * 1.0 end  # from_basis
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

        def unquote(name)() do 
          {
            __MODULE__, 
            unquote(name), 
            revert_lambda(unquote(expr)),  # to_basis 
            create_lambda(unquote(expr))   # from_basis
          }
        end

        def unquote(name)(value) do 
          {
            apply(__MODULE__, unquote(name), []),
            value * 1.0
          }
        end

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
              true -> 
                define_internal_type(
                  unquote(name), 
                  unquote(rest)
                )  
            end
        end
      end
    end
    

    @doc false
    defmacro type(_value) do 
      raise RuntimeError, 
        message: "The line is unparsable"
    end


  end
  

  def unwrap({_, value}), do: value

end
