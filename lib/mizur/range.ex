defmodule Mizur.Range do

  @moduledoc false

  defmacro __using__(_opts) do
    quote do
      import Mizur.Range


      @typedoc """
      This type represents a range of `typed_value`.
      """
      @type range :: __MODULE__.Range.t


      defmodule Range do

        @parent __MODULE__
          |> Module.split
          |> Enum.drop(-1)
          |> Module.concat

        @moduledoc """
        This module provides a minimalistic approach of Range between
        two #{@parent} types.
        """

        @typedoc """
        This type represents a range of typed_value.
        """
        @type t :: %__MODULE__{
    a: @parent.t,
    b: @parent.t
  }

  @enforce_keys [:a, :b]
  defstruct [:a, :b]


        @doc """
        Builds a range between two `typed_value`.
        """
        @spec new(@parent.t, @parent.t) :: t
        def new(%@parent{} = a, %@parent{} = b) do
          %__MODULE__{a: a, b: @parent.from(b, to: a.type)}
        end

        @doc """
        Checks if a range is increasing.
        """
        @spec increasing?(t) :: boolean
        def increasing?(%__MODULE__{} = t) do
          @parent.compare(t.a, to: t.b) in [:lt, :eq]
        end

        @doc """
        Checks if a range is decreasing.
        """
        @spec decreasing?(t) :: boolean
        def decreasing?(%__MODULE__{} = range) do
          not increasing?(range)
        end

        @doc """
        Sorts a range
        """
        @spec sort(t) :: t
        def sort(%__MODULE__{} = t) do
          case @parent.compare(t.a, to: t.b) do
            :lt -> t
            _ -> new(t.b, t.a)
          end
        end

        @doc """
        Returns the first element of the range
        """
        @spec first(t) :: @parent.t
        def first(%__MODULE__{} = t) do
    t.a
        end

        @doc """
        Returns the last element of the range
        """
        @spec last(t) :: @parent.t
        def last(%__MODULE__{} = t) do
    t.b
        end

        @doc """
        Returns the smallest element of the `range`
        """
        @spec min(t) :: @parent.t
        def min(%__MODULE__{} = range) do
          range
          |> sort()
          |> first()
        end

        @doc """
        Returns the biggest element of the range
        """
        @spec max(t) :: @parent.t
        def max(%__MODULE__{} = range) do
          range
          |> sort()
          |> last()
        end

        @doc """
        Returns a reversed version of a range
        """
        @spec reverse(t) :: t
        def reverse(%__MODULE__{} = t), do: new(t.b, t.a)

        @doc """
        Checks if a `typed_value` is included in a range.
        """
        @spec include?(@parent.t, [in: t]) :: boolean
        def include?(value, in: %__MODULE__{} = t) do
          real = sort(t)
          x = @parent.compare(value, to: real.a)
          y = @parent.compare(value, to: real.b)
          (x in [:eq, :gt]) and (y in [:eq, :lt])
        end

        @doc """
        Checks if two ranges overlap.
        """
        @spec overlap?(t, t) :: boolean
        def overlap?(%__MODULE__{} = a, %__MODULE__{} = b) do
          %__MODULE__{a: startA, b: endA} = sort(a)
          %__MODULE__{a: startB, b: endB} = sort(b)
          x = @parent.compare(startA, to: endB)
          y = @parent.compare(endA, to: startB)
          (x in [:eq, :lt]) and (y in [:eq, :gt])
        end

        @doc """
        Tests if a range is a subrange of another range.
        """
        @spec subrange?(t, of: t) :: boolean
        def subrange?(%__MODULE__{} = a, of: %__MODULE__{} = b) do
          %__MODULE__{a: x, b: y} = sort(a)
          include?(x, in: b) and include?(y, in: b)
        end

        @doc false
        defp foldl_aux(acc, f, %__MODULE__{a: current, b: max}, step, {next, flag}) do
          cond do
            @parent.compare(current, to: max) == flag ->
              new_acc = f.(acc, current)
              next_step = @parent.map2(current, step, next)
              foldl_aux(new_acc, f, new(next_step, max), step, {next, flag})
            true -> f.(acc, max)
          end
        end

        @doc """
        Folds (reduces) the given range from the left with a function.
        Requires an accumulator. The step can be nil, and the step will
        be "one by one" of the general type of the range, but you can
        specify a module, or a typed value.
        """
        @spec foldl(
          t,
          (@parent.t, any -> any),
          any,
          nil | @parent.t | @parent.Type.t
        ) :: any
        def foldl(%__MODULE__{} = range, f, default, step \\ nil) do
          real_step = case step do
            nil ->
              a = first(range)
              %{a | value: 1}
            %@parent.Type{} = data -> %@parent{type: data, value: 1.0}
            data -> data
          end
          data = if (increasing?(range)), do: {&+/2, :lt}, else: {&-/2, :gt}
          foldl_aux(default, f, range, real_step, data)
        end

        @doc """
        Folds (reduces) the given range from the left with a function.
        Requires an accumulator. The step could be nil, and the step will
        be "one by one" of the general type of the range, but you can
        specify a module, or a typed value.
        """
        @spec foldr(
          t,
          (@parent.t, any -> any),
          any,
          nil | @parent.t | @parent.Type.t
        ) :: any
        def foldr(%__MODULE__{} = range, f, default, step \\ nil) do
          range
          |> reverse()
          |> foldl(f, default, step)
        end

        @doc """
        Converts a range to a list of `typed_value`.
        The step can be nil, and the step will
        be "one by one" of the general type of the range, but you can
        specify a type of the module, or a typed value of the module.
        """
        @spec to_list(t, nil | @parent.t | @parent.Type.t) :: [@parent.t]
        def to_list(%__MODULE__{} = range, step \\ nil) do
          range
          |> foldr(fn(acc, x) -> [ x | acc ] end, [], step)
        end

      end # End of Range


    end # End of quote
  end

end
