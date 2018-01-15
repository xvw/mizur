defmodule Mizur.Implementation do
  @moduledoc false

  defmacro __using__(_opts) do
    quote do
      defimpl String.Chars, for: __MODULE__.Type do
        def to_string(element) do
          Atom.to_string(element.name)
        end
      end

      defimpl String.Chars, for: __MODULE__ do
        def to_string(element) do
          "#{element.value}<#{element.type}>"
        end
      end

      defimpl String.Chars, for: __MODULE__.Range do
        def to_string(element) do
          "(#{element.a} .. #{element.b})"
        end
      end
    end
  end
end
