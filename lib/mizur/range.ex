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
        @moduledoc """
        This module provides a minimalistic approach of Range between 
        two #{__MODULE__} types.
        """

        @typedoc """
        This type represents a range of `typed_value`.
        """
        @type t :: {__MODULE__.t, __MODULE__.t}

      end
      

    end
  end

end
