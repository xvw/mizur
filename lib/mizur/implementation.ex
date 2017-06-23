defmodule Mizur.Implementation do 

  @moduledoc false

  defmacro __using__(_opts) do 
    quote do 

      defimpl String.Chars, for: __MODULE__.Type do 
        def to_string(element) do 
          "test"
        end
      end

    end
  end

end
