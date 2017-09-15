defmodule Mizur do

  @moduledoc """
  **Mizur** is a tool to simplify the management, conversions  
  and mapping of units. 

  The manipulation of units of measurement try (at best) 
  to be typesafe.

  ## Example 
  For example, let's write a System for the length

  ```elixir
  module Length do
    use Mizur

    type m
    type dm = m / 10
    type cm = m / 100
    type mm = cm / 10 
    type km = 1000 * m

  end
  ```

  """

  defmacro __using__(_opts) do 
    quote do 
      use Mizur.System
      use Mizur.Implementation
      use Mizur.Api
      use Mizur.Range
    end
  end

  # Sample (to test documentation)
  defmodule APIExample do 
    use Mizur.System
    use Mizur.Implementation
    use Mizur.Api
    use Mizur.Range
  end

end
