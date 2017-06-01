defmodule Mizur do

  @moduledoc """
  **Mizur** is a tool to simplify the management, conversions  
  and mapping of units. 

  The manipulation of units of measurement try (at best) 
  to be typesafe.
  """


  defmodule Length do 
    use Mizur.System
    type m
    type cm = (1 / 100) * m
    type mm = (cm / 10)
  end
  

end
