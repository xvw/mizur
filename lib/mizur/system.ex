defmodule Mizur.System do
  @moduledoc false

  @doc false
  defmacro __using__(_opts) do
    quote do
      import Mizur.System

      @metrics []

      defmodule Type do
        @moduledoc """
        Internal representation of a **typed** value for a
        module which uses `Mizur.System`.
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

      # End of Type

      @typedoc """
      This type represents a subtype of a `typed_value`.
      """
      @type subtype :: Type.t()

      @typedoc """
      This type represents a `typed_value`.
      """
      @type t :: %__MODULE__{
              type: subtype,
              value: float
            }

      # Struct to define a typed values
      @enforce_keys [:type, :value]
      defstruct [:type, :value]
    end

    # End of Internal module
  end

  # End of using

  @doc false
  defmacro define_basis(basis) do
    quote do
      @metrics [unquote(basis) | @metrics]
      define_internal_type(
        unquote(basis),
        :mizur_internal_value
      )
    end
  end

  @doc false
  defmacro lambda(expr) do
    f = quote do: mizur_internal_value

    r =
      Macro.postwalk(expr, fn elt ->
        case elt do
          x when is_atom(x) ->
            quote do: unquote({x, [], __MODULE__})

          {l, _, nil} when is_atom(l) ->
            quote do
              apply(__MODULE__, unquote(l), []).to_basis.(unquote(f))
            end

          _ ->
            elt
        end
      end)

    quote do: fn mizur_internal_value -> unquote(r) end
  end

  @doc false
  defp revert_operator(op) do
    case op do
      :+ ->
        :-

      :- ->
        :+

      :* ->
        :/

      :/ ->
        :*

      _ ->
        raise RuntimeError, message: "#{op} is an unknown operator"
    end
  end

  @doc false
  def revert(expr, acc \\ {:mizur_internal_value, [], __MODULE__}) do
    case expr do
      {e, _, nil} ->
        {e, acc}

      {op, _, [left, right]}
      when is_number(left) ->
        new_acc = {revert_operator(op), [], [acc, left]}
        revert(right, new_acc)

      {op, _, [right, left]}
      when is_number(left) ->
        new_acc = {revert_operator(op), [], [acc, left]}
        revert(right, new_acc)

      {op, _, [left, {_, [], nil}]} ->
        {revert_operator(op), [], [acc, left]}

      {op, _, [{_, [], nil}, left]} ->
        {revert_operator(op), [], [acc, left]}

      _ ->
        IO.inspect(b: expr)
        acc
    end
  end

  @doc false
  defmacro rev_lambda(expr) do
    # new_expr = revert(expr, quote do: (mizur_internal_value))
    case expr do
      x when is_number(x) ->
        quote do: fn _ -> unquote(x) end

      :mizur_internal_value ->
        quote do: fn mizur_internal_value -> mizur_internal_value end

      _ ->
        epr =
          Macro.postwalk(expr, fn elt ->
            case elt do
              {op, _, [a, b]} when is_number(a) and is_number(b) ->
                apply(Kernel, op, [a, b])

              fresh ->
                fresh
            end
          end)

        {at, ex} = revert(epr)

        new_expr =
          Macro.postwalk(ex, fn elt ->
            case elt do
              {:mizur_internal_value, _, __MODULE__} ->
                quote do
                  apply(__MODULE__, unquote(at), []).from_basis.(mizur_internal_value)
                end

              fresh ->
                fresh
            end
          end)

        quote do
          fn mizur_internal_value ->
            unquote(new_expr)
          end
        end
    end
  end

  @doc false
  defmacro define_internal_type(name, expr) do
    quote do
      @metrics [unquote(name) | @metrics]

      @doc """
      References the subtype `#{unquote(name)}`
      of `#{__MODULE__}.Type`
      """
      @spec unquote(name)() :: __MODULE__.Type.t()
      def unquote(name)() do
        %__MODULE__.Type{
          name: unquote(name),
          from_basis: rev_lambda(unquote(expr)),
          to_basis: lambda(unquote(expr))
        }
      end

      @doc """
      Builds a value into the subtype `#{unquote(name)}`
      of `#{__MODULE__}.Type`
      """
      @spec unquote(name)(number) :: __MODULE__.t()
      def unquote(name)(value) do
        %__MODULE__{
          type: apply(__MODULE__, unquote(name), []),
          value: value * 1.0
        }
      end

      @doc """
      A shortcut to write `typed_value`. using sigils notation.

      For example :
          iex> import #{__MODULE__}
          ...> ~M(200)#{unquote(name)}
          #{__MODULE__}.#{unquote(name)}(200)
      """
      def sigil_M(value, unquote(to_charlist(name))) do
        apply(__MODULE__, unquote(name), [String.to_integer(value)])
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
