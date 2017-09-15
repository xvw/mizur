defmodule Mizur.Range do 

  @moduledoc false

  defmacro __using__(_opts) do 
    quote do 
      import Mizur.Range


      @typedoc """
      This type represents a range of `typed_value`.
      """
      @type range :: {
        __MODULE__.Range.t, 
        __MODULE__.Range.t
      }


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
        @type t :: {@parent.t, @parent.t}


        @doc """
        Builds a range between two `typed_value`.
        """
        @spec new(@parent.t, @parent.t) :: t
        def new(%@parent{} = a, %@parent{} = b) do 
          {a, @parent.from(b, to: a.type)}
        end

        @doc """
        Checks if a range is increasing.
        """
        @spec increasing?(t) :: boolean
        def increasing?({%@parent{} = a, %@parent{} = b}) do
          @parent.compare(a, to: b) in [:lt, :eq]
        end

        @doc """
        Checks if a range is decreasing.
        """
        @spec decreasing?(t) :: boolean
        def decreasing?(range) do
          not increasing?(range)
        end

        @doc """
        Sorts a range
        """
        @spec sort(t) :: t
        def sort({%@parent{} = a, %@parent{} = b}) do 
          case @parent.compare(a, to: b) do
            :lt -> {a, b}
            _ -> {b, a}
          end
        end

        @doc """
        Returns the first element of the range
        """
        @spec first(t) :: @parent.t
        def first(range) do 
          {x, _} = range 
          x
        end

        @doc """
        Returns the latest element of the range
        """
        @spec last(t) :: @parent.t
        def last(range) do 
          {_, x} = range 
          x
        end

        @doc """
        Returns the smallest element of the `range`
        """
        @spec min(t) :: @parent.t
        def min(range) do 
          range 
          |> sort()
          |> first()
        end

        @doc """
        Returns the biggest element of the range
        """
        @spec max(t) :: @parent.t
        def max(range) do 
          range 
          |> sort()
          |> last()
        end

        @doc """
        Returns a reversed version of a range
        """
        @spec reverse(t) :: t
        def reverse({a, b}), do: {b, a}

        @doc """
        Checks if a `typed_value` is included in a range.
        """
        @spec include?(@parent.t, [in: t]) :: boolean
        def include?(value, in: range) do 
          {a, b} = sort(range)
          x = @parent.compare(value, to: a)
          y = @parent.compare(value, to: b)
          (x in [:eq, :gt]) and (y in [:eq, :lt])
        end

        @doc """
        Checks if two ranges overlap.
        """
        @spec overlap?(t, t) :: boolean 
        def overlap?(a, b) do 
          {startA, endA} = sort(a)
          {startB, endB} = sort(b)
          x = @parent.compare(startA, to: endB)
          y = @parent.compare(endA, to: startB)
          (x in [:eq, :lt]) and (y in [:eq, :gt])
        end

        @doc """
        Tests if a range is a subrange of another range.
        """
        @spec subrange?(t, of: t) :: boolean
        def subrange?(a, of: b) do 
          {x, y} = sort(a)
          include?(x, in: b) and include?(y, in: b)
        end

        @doc false 
        defp foldl_aux(acc, f, {current, max}, step, {next, flag}) do 
          cond do 
            @parent.compare(current, to: max) == flag ->
              new_acc = f.(acc, current)
              next_step = @parent.map2(current, step, next)
              foldl_aux(new_acc, f, {next_step, max}, step, {next, flag})
            true -> f.(acc, max)
          end
        end

        @doc """
        Folds (reduces) the given range from the left with a function. 
        Requires an accumulator. The step could be nil, and the step will 
        be "one by one" of the general type of the range, but you can 
        specify a type of the module, or a typed value of the module.
        """
        @spec foldl(
          t, 
          (@parent.t, any -> any), 
          any, 
          nil | @parent.t | @parent.Type.t
        ) :: any
        def foldl(range, f, default, step \\ nil) do 
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
        specify a type of the module, or a typed value of the module.
        """
        @spec foldr(
          t, 
          (@parent.t, any -> any), 
          any, 
          nil | @parent.t | @parent.Type.t
        ) :: any
        def foldr(range, f, default, step \\ nil) do 
          range 
          |> reverse() 
          |> foldl(f, default, step)
        end

        @doc """
        Converts a range to a list of `typed_value`. 
        The step could be nil, and the step will 
        be "one by one" of the general type of the range, but you can 
        specify a type of the module, or a typed value of the module.
        """
        @spec to_list(t, nil | @parent.t | @parent.Type.t) :: [@parent.t]
        def to_list(range, step \\ nil) do 
          range 
          |> foldr(fn(acc, x) -> [ x | acc ] end, [], step)
        end

        @doc """
        Convert a range into a string (to be inspected !)
        """
        @spec to_string(t) :: charlist 
        def to_string({a, b}) do 
          "#{@parent.to_string(a)}..#{@parent.to_string(b)}"
        end

      end # End of Range
      

    end # End of quote
  end

end
