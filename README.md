# Mizur
Pronounced `/'meʒə/`

**Mizur** is a tool to simplify the management, conversions  
and mapping of units. 
The manipulation of units of measurement try (at best) 
to be typesafe.

![Mizur Logo](images/logo.png)
(A special thanks to [@fh-d](https://github.com/fh-d) for this awesome logo !)

- [Presentation](#content)
- [Some example](#some-examples)
- [Installation](#installation)
- [Special thanks](#special-thanks)

## Some examples

### Basic example

Definition of a metric system for computing distances :

```elixir 

defmodule Distance do 
  use Mizur.System
  type m
  type cm = m / 100 
  type mm = m / 1000 
  type km = m * 1000
end

```

#### Usage of the system

```elixir
a = Distance.m(200)
b = Distance.cm(200)
result = Mizur.add(a, b)
assert result = Distance.m(202)
```

### Manage arithmetic operations on datetime

```elixir 
defmodule MyTime do 

  use Mizur.System
  type sec
  type min  = sec * 60 
  type hour = sec * 60 * 60
  type day  = sec * 60 * (60 * 24)

  def now do 
    DateTime.utc_now()
    |> DateTime.to_unix(:second)
    |> sec()
  end

  def new(year, month, day, hour, min, sec) do
    ndt = NaiveDateTime.new(year, month, day, hour, min, sec) 
    case ndt do 
      {:error, message} -> raise RuntimeError, message: "#{message}"
      {:ok, value} ->
        DateTime.from_naive!(value, "Etc/UTC")
        |> DateTime.to_unix(:second)
        |> sec()
    end
  end

  def to_datetime(value) do 
    elt = Mizur.from(value, to: sec())
    int = round(Mizur.unwrap(elt))
    DateTime.from_unix!(int) #beurk, it is unsafe
  end
  
end

use Mizur.Infix, only: [+: 2, -: 2]
import MyTime

# Create a typed_value of the current timestamp:
a = now()

# Add two days and four hour
b = a + ~t(2)day + ~t(4)hour # I use Sigils... 

# Sub ten minuts 
c = b - ~t(10)min

# Convert into DateTime 
result = to_datetime(c)
```

### Other examples

The test module gives many examples of uses :
[Test module](https://github.com/xvw/mizur/blob/master/test/mizur_test.exs)

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `mizur` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:mizur, "~> 0.1.0"}]
end
```

## Special Thanks

- [@julien-leclercq](https://github.com/julien-leclercq), a lot of help about unit-comprehension
- [@Fenntasy](https://github.com/Fenntasy), help for the design
- [@fh-d](https://github.com/fh-d), for the logo
- [@tgautier](https://github.com/tgautier) and the LilleFP team !

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/mizur](https://hexdocs.pm/mizur).

