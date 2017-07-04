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
        two #{@parent} types. A Range could be considered as a Vector2D.
        """

        @typedoc """
        This type represents a range of `typed_value`.
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
        Checks if a `range` is increasing.
        """
        @spec increasing?(t) :: boolean
        def increasing?({%@parent{} = a, %@parent{} = b}) do
          @parent.compare(a, to: b) in [:lt, :eq]
        end

        @doc """
        Checks if a `range` is decreasing.
        """
        @spec decreasing?(t) :: boolean
        def decreasing?(range) do
          not increasing?(range)
        end

        @doc """
        Sorts a `range`.
        """
        @spec sort(t) :: t
        def sort({%@parent{} = a, %@parent{} = b}) do 
          case @parent.compare(a, to: b) do
            :lt -> {a, b}
            _ -> {b, a}
          end
        end

        @doc """
        Returns the first element of the `range`
        """
        @spec first(t) :: @parent.t
        def first(range) do 
          {x, _} = range 
          x
        end

        @doc """
        Returns the latest element of the `range`
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
        Returns the biggest element of the `range`
        """
        @spec max(t) :: @parent.t
        def max(range) do 
          range 
          |> sort()
          |> last()
        end

        @doc """
        Returns a reversed version of a `range`
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

      end # End of Range
      

    end # End of quote
  end

end
