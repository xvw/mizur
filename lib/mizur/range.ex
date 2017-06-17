defmodule Mizur.Range do 

  @moduledoc """
  This module provides a minimalistic approach of Range between 
  `typed_value`. A range is characterized by two values and a 
  direction. The two values must necessarily be different.
  """

  defmacro __using__(_opts) do 
    quote do 
      import Mizur.Range


      @typedoc """
      This type represents a range of `typed_value`.
      """
      @type range :: {t, t}

      defmodule Range do 
        @moduledoc """
        This module provides a minimalistic approach of Range between 
        two #{__MODULE__} types.
        """
      end
      

    end
  end

end
