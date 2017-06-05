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
                apply(__MODULE__, unquote(l), []).to_basis.(unquote(f))
              end
            _ -> elt
          end
        end)
    quote do: (fn(mizur_internal_value) -> unquote(r) end)
  end


  @doc false 
  def revert(expr) do 
    case expr do 
      {:+, _, [a, b]} when is_number(a) or is_atom(a) -> 
        {:/, [], [{:-, [], [0, a]}, b]}
      {:-, _, [a, b]} when is_number(a) or is_atom(a) -> 
        {:/, [], [{:+, [], [0, a]}, b]}
      {:+, _, [a, b]} when is_number(b) or is_atom(b) -> 
        {:/, [], [{:-, [], [0, b]}, a]}
      {:-, _, [a, b]} when is_number(b) or is_atom(b) -> 
        {:/, [], [{:+, [], [0, b]}, a]}
      {:*, _, [a, b]} -> {:/, [], [b, a]}
      {:/, _, [a, b]} -> {:*, [], [b, a]}
    end
  end


  @doc false 
  defmacro rev_lambda(expr) do 
    #new_expr = revert(expr, quote do: (mizur_internal_value)) 
    case expr do 
      x when is_number(x) -> 
        quote do: (fn(_) -> unquote(x) end)
      :mizur_internal_value -> 
        quote do: (fn(mizur_internal_value) -> mizur_internal_value end)
      _ -> 
        f = quote do: (mizur_internal_value)
        new_expr =
          Macro.postwalk(revert(expr), fn(elt) ->
            case elt do
              {op, _, [a, b]} when is_number(a) and is_number(b) -> 
                apply(Kernel, op, [a, b])
              {key, _, nil} -> 
                quote do
                  apply(__MODULE__, unquote(key), []).
                  from_basis.(unquote(f))
                end 
              _ -> elt 
            end
          end)
        quote do
          (fn(mizur_internal_value) -> unquote(new_expr) end)
        end
      end
  end


  @doc false 
  defmacro define_internal_type(name, expr) do
    is = String.to_atom("is_" <> Atom.to_string(name))
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
