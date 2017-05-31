defmodule Mizur.System do

  @moduledoc """
  **Mizur.System** provides Macro to promote a Module to 
  a System (with internal units of measure).
  """

  @doc false
  defmacro __using__(_opts) do 
    quote do 

      import Mizur.System

      @basis nil 

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
      end

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

    end
  end

end
