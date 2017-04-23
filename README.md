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

```elixir
a = Distance.m(200)
b = Distance.cm(200)
result = Mizur.add(a, b)
assert result = Distance.m(202)
```

#### Usage of the system



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

