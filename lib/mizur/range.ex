defmodule Mizur.Range do 

  @moduledoc false

  defmacro __using__(_opts) do 
    quote do 
      import Mizur.Range


      @typedoc """
      This type represents a range of `typed_value`.
      """
      @type range :: {__MODULE__.Range.t, __MODULE__.Range.t}


      defmodule Range do 

        @parent __MODULE__ |> Module.split |> Enum.drop(-1) |> Module.concat

        @moduledoc """
        This module provides a minimalistic approach of Range between 
        two #{@parent} types.
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

      end
      

    end
  end

end
