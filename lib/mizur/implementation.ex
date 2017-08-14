defmodule Mizur.Implementation do

  @moduledoc false

  defmacro __using__(_opts) do
    quote do
      defimpl String.Chars, for: __MODULE__ do
        def to_string(element) do
          to_string(element.value) <> to_string(element.type.name)
        end
      end
    end
  end
end
