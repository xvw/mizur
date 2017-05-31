defmodule Mizur.System do

  @moduledoc """
  **Mizur.System** provides Macro to promote a Module to 
  a System (with internal units of measure).
  """

  @doc false
  defmacro __using__(_opts) do 
    quote do 

      import Mizur.System

      @metrics []

      defmodule Type do 
        @moduledoc """
        Internal representation of a **typed** value for a 
        module who is using `Mizur.System`.
        """

        @typedoc """
        This type represents a System's type.
        """
        @type t :: %Type{
          name: atom, 
          from_basis: (number -> float),
          to_basis: (number -> float)
        }


        # Struct to define a type
        @enforce_keys [:name, :from_basis, :to_basis]
        defstruct [:name, :from_basis, :to_basis]

      end # End of Type

      @typedoc """
      This type represents a **Typed value**.
      """
      @type t :: %__MODULE__{
        type: Type.t, 
        value: float
      }

      # Struct to define a typed values
      @enforce_keys [:type, :value]
      defstruct [:type, :value]

    end # End of Internal module

  end # End of using

  @doc false
  defmacro define_basis(basis) do 
    quote do 
      @metrics [ unquote(basis) | @metrics]
      define_internal_type(
        unquote(basis), 
        :mizur_internal_value
      )
    end
  end

  defmacro revert(expr, acc) do 
    quote do 
      case unquote(expr) do 
        {:mizur_internal_value, [], Mizur.System} -> unquote(acc)
        r -> IO.inspect r
      end
    end
  end

  @doc false 
  defmacro define_internal_type(name, expr) do
    mit = {:mizur_internal_value, [], __MODULE__}
    new_expr = if is_atom(expr), do: mit, else: expr
    quote do 
      def unquote(name)() do 
        %__MODULE__.Type{
          name: unquote(name), 
          from_basis: 
            fn(mizur_internal_value) -> 
              unquote(lambda(new_expr)) * 1.0 
            end,
          to_basis: 1.0
        }
      end
    end
  end


  @doc """
  """
  defmacro type({basis, _, nil}) do 
    quote do 
      define_basis(unquote(basis))
    end
  end

  @doc """
  """
  defmacro type({:=, _, [{name, _, nil}, rest]}) do 
    quote do 
      define_internal_type(unquote(name), unquote(rest))
    end
  end

end
