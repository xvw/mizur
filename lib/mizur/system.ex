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

  @doc false 
  defmacro lambda(expr) do 
    f = quote do: (mizur_internal_value)
    r = Macro.postwalk(expr, fn(elt) ->
      case elt do 
        x when is_atom(x) -> 
          quote do: unquote({x, [], __MODULE__})
        {l, _, nil} when is_atom(l) -> 
          quote do
            cond do 
              !Enum.member?(@metrics, unquote(l)) -> 
                raise(
                  RuntimeError, 
                  message: "[#{unquote(l)}] does not exists."
                )
                true ->
                  apply(
                    __MODULE__, 
                    unquote(l), 
                    []
                  ).to_basis.(unquote(f))
              end 
          end
        _ -> elt
      end
    end)
    quote do: fn(mizur_internal_value) -> unquote(r) end
  end

  @doc false 
  defmacro rev_lambda(_expr) do 
    #r = Macro.postwalk(expr, fn(elt) -> elt end)
    quote do: fn(mizur_internal_value) -> 10 end
  end


  @doc false 
  defmacro define_internal_type(name, expr) do
    quote do 
      @metrics [unquote(name) | @metrics]

      @doc """
      References the subtype `#{unquote(name)}` 
      of `#{__MODULE__}.Type`
      """
      @spec unquote(name)() :: __MODULE__.Type.t
      def unquote(name)() do 
        %__MODULE__.Type{
          name: unquote(name), 
          from_basis: rev_lambda(unquote(expr)),
          to_basis:  lambda(unquote(expr))
        }
      end

      @doc """
      Builds a value into the subtype `#{unquote(name)}`
      of `#{__MODULE__}.Type`
      """
      @spec unquote(name)(number) :: __MODULE__.t
      def unquote(name)(value) do 
        %__MODULE__{
          type: apply(__MODULE__, unquote(name), []), 
          value: value * 1.0
        }
      end

      @doc """
      A shortcut to write **typed values** using sigils notation. 
      
      For example : 
          iex> import #{__MODULE__}
          ...> ~M(200)#{unquote(name)}
          #{__MODULE__}.#{unquote(name)}(200)
      """
      def sigil_M(value, unquote(to_charlist(name))) do 
        apply(
          __MODULE__, 
          unquote(name), 
          [String.to_integer(value)]
        )
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
