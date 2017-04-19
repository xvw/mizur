# Mizur
Pronounced `/'meʒə/`

**Mizur** is a tool to simplify the management, conversions  
and mapping of units. 
The manipulation of units of measurement try (at best) 
to be typesafe.

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

#### Usage of the metric-system

to be done

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

## Special Thanks ! 

- [@julien-leclercq](https://github.com/julien-leclercq), a lot of help about unit-comprehension
- [@Fenntasy](https://github.com/Fenntasy), help for the design
- [@tgautier](https://github.com/tgautier) and the LilleFP team !

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/mizur](https://hexdocs.pm/mizur).

