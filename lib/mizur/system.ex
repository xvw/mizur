defmodule Mizur.System do 

  @moduledoc """
  Sets up a metric system.

  This module must be used in another module to define a metric system.
  Using this module provide functions to builds typed values.

  When used, it accepts the following options:

  - `:intensive` : defined a metric system as using intensive measurements.
      An intensive system prohibits arithmetic operations between units. 
      It only allows conversions.

  ## Example 

  ```
  defmodule Distance do 
    use Mizur.System

    type m # m is used as a reference
    type cm = m / 100 
    type mm = m / 1000 
    type km = m * 1000

  end
  ```

  """

  @doc false
  defmacro __using__(opts) do 
    quote do 
      import Mizur.System
      @basis nil
      @metrics []
      @before_compile Mizur.System
      @intensive !!unquote(opts)[:intensive]
    end
  end


  @doc false
  defmacro __before_compile__(_env) do
    quote do
      def system_metric do
        %{
          units: @metrics,
          intensive?: @intensive
        }
      end
    end
  end


  @doc false 
  defp rev_operator(op) do 
    case op do 
      :+ -> :- 
      :- -> :+ 
      :* -> :/
      :/ -> :*
      _  -> 
        raise RuntimeError, 
          message: "#{op} is an unknown operator"
    end
  end

  @doc false 
  defp revert_expr(acc, f_expr) do 
    expr = Macro.postwalk(
      f_expr, 
      fn(elt) -> 
        case elt do 
          {op, _, [a, b]} when is_number(a) and is_number(b) ->
            apply(Kernel, op, [a, b])
          _ -> elt
        end
      end
    )
    case expr do 
      {_, _, nil} -> acc
      {op, _, [left, right]} 
        when is_number(left) ->
          new_acc = {rev_operator(op), [], [acc, left]}
          revert_expr(new_acc, right)
      {op, _, [right, left]} 
        when is_number(left) ->
          new_acc = {rev_operator(op), [], [acc, left]}
          revert_expr(new_acc, right)
      {op, _, [left, {_, _, nil}]} ->
          {rev_operator(op), [], [acc, left]}
      {op, _, [{_, _, nil}, left]} ->
          {rev_operator(op), [], [acc, left]}
      _ -> 
        acc
    end
  end


  @doc false 
  defmacro create_lambda(expr) do 
    formatted = Macro.postwalk(expr, fn(elt) -> 
      case elt do 
        {x, _, nil} when is_atom(x) -> {:basis, [], __MODULE__}
        {x, _, t_elt} -> {x, [], t_elt}
        _ -> elt
      end
    end)
    quote do: (fn(basis) -> unquote(formatted) end)
  end

  @doc false 
  defmacro revert_lambda(expr) do 
    fexpr = revert_expr({:target, [], __MODULE__}, expr)
    formatted = Macro.postwalk(
      fexpr, 
      fn(elt) -> 
        case elt do 
          {x, _, nil} when is_atom(x) -> {:target, [], __MODULE__}
          {x, _, t_elt} -> {x, [], t_elt}
          _ -> elt
        end
      end
    )
    quote do: fn(target) -> unquote(formatted) end
  end
  

  @doc false
  defmacro define_basis(basis) do 

    quote do 

      @basis unquote(basis)
      @metrics [unquote(basis) | @metrics]



      Module.add_doc(
        __MODULE__, __ENV__.line + 3, 
        :def, {unquote(basis), 0}, [], 
        "References the type `#{unquote(basis)}`"
      )
      def unquote(basis)() do 
        {
          __MODULE__, 
          unquote(basis),
          @intensive,
          fn(x) -> x * 1.0 end, # from_basis
          fn(x) -> x * 1.0 end  # to_basis
        }
      end

      Module.add_doc(
        __MODULE__, __ENV__.line + 3, 
        :def, {unquote(basis), 1}, [:value], 
        "Builds a value into `#{unquote(basis)}`"
      )
      def unquote(basis)(value) do 
        {
          apply(__MODULE__, unquote(basis), []),
          value * 1.0
        }
      end

      Module.add_doc(
        __MODULE__, __ENV__.line + 3, 
        :def, {:sigil_t, 2}, [:value, :charlist], 
        false
      )
      def sigil_t(value, unquote(to_charlist(basis))) do
        apply(
          __MODULE__, 
          unquote(basis), 
          [String.to_integer(value)]
        )
      end
      
      
    end
  end


  @doc false
  defmacro define_internal_type(name, expr) do 


    quote do 
      @metrics [unquote(name) | @metrics]

      Module.add_doc(
        __MODULE__, __ENV__.line + 3, 
        :def, {unquote(name), 0}, [], 
        "References the type `#{unquote(name)}`"
      )
      def unquote(name)() do 
        {
          __MODULE__, 
          unquote(name), 
          @intensive,
          revert_lambda(unquote(expr)),   # from_basis 
          create_lambda(unquote(expr))    # to_basis
        }
      end

      Module.add_doc(
        __MODULE__, __ENV__.line + 3, 
        :def, {unquote(name), 1}, [:value], 
        "Builds a value into `#{unquote(name)}`"
      )
      def unquote(name)(value) do 
        {
          apply(__MODULE__, unquote(name), []),
          value * 1.0
        }
      end

      Module.add_doc(
        __MODULE__, __ENV__.line + 3, 
        :def, {:sigil_t, 2}, [:value, :charlist], 
        false
      )
      def sigil_t(value, unquote(to_charlist(name))) do 
        apply(
          __MODULE__, 
          unquote(name), 
          [String.to_integer(value)]
        )
      end

    end
  end

  
  @doc """
  Defines the metric system reference unit. For example, 
  `m` in the distance system :

  ```
  defmodule Distance do 
    use Mizur.System

    type m # m is used as a reference
    type cm = m / 100 
    type mm = m / 1000 
    type km = m * 1000

  end
  ```

  - You can only use one reference unit.
  - In the expression to define the ratio between a unit 
    and its reference, only the reference can be used as variable 
    and the operators: `+`, `*`, `-` and `/`.

  """
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
  
  defmacro type(_value) do 
    raise RuntimeError, 
      message: "The line is unparsable"
  end


end