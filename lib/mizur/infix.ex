defmodule Mizur.Infix do


  @moduledoc """
  This module offers infix versions of the common functions 
  of the Mizur module.

  When used, it accepts the following options:

  - `:only` : same of `:only` in importation 
  - `:except` : same of `:except` in importation 

  """

  @doc false
  defmacro __using__(opts) do 

    operators = [
      +:   2, 
      -:   2, 
      *:   2, 
      /:   2, 
      ==:  2,
      !=:  2,
      ===: 2, 
      !==: 2,
      >:   2, 
      <:   2, 
      <=:  2, 
      >=:  2,
      in:  2,
      ..: 2
    ]

    except = opts[:except] || []
    only = opts[:only] || operators
    all = only -- except

    quote do 
      import Kernel, except: unquote(all)
      import Mizur.Infix, only: unquote(all)
    end
  end

  @doc """
  Infix version of `from/2`.

  For example:
      iex> import Mizur.Infix, only: [~>: 2]
      ...> MizurTest.Distance.cm(100) ~> MizurTest.Distance.m
      {MizurTest.Distance.m, 1.0}
  """
  @spec Mizur.typed_value ~> Mizur.metric_type :: Mizur.typed_value
  def base ~> to do 
    Mizur.from(base, to: to)
  end

  @doc """
  Infix (and reverted) version of `from/2`.

  For example:
      iex> import Mizur.Infix, only: [<~: 2]
      ...> MizurTest.Distance.m <~ MizurTest.Distance.cm(100) 
      {MizurTest.Distance.m, 1.0}
  """
  @spec Mizur.metric_type <~ Mizur.typed_value :: Mizur.typed_value
  def to <~ base do 
    base ~> to
  end


  @doc """
  Infix version of `Mizur.add/2` :

      iex> use Mizur.Infix, only: [+: 2]
      ...> a = MizurTest.Distance.cm(12)
      ...> b = MizurTest.Distance.m(2)
      ...> a + b
      MizurTest.Distance.cm(212)
  """
  @spec Mizur.typed_value + Mizur.typed_value :: Mizur.typed_value
  def a + b do 
    Mizur.add(a, b)
  end

  @doc """
  Infix version of `Mizur.sub/2`:
  
      iex> use Mizur.Infix, only: [-: 2]
      ...> a = MizurTest.Distance.cm(12)
      ...> b = MizurTest.Distance.m(2)
      ...> b - a
      MizurTest.Distance.m(1.88)
  """
  @spec Mizur.typed_value - Mizur.typed_value :: Mizur.typed_value
  def a - b do 
    Mizur.sub(a, b)
  end

  @doc """
  Infix version of `Mizur.mult/2`:

      iex> use Mizur.Infix, only: [*: 2]
      ...> a = MizurTest.Distance.cm(12)
      ...> a * 10
      MizurTest.Distance.cm(120)
  """
  @spec Mizur.typed_value * number :: Mizur.typed_value 
  def a * b do 
    Mizur.mult(a, b)
  end

  @doc """
  Infix version of `Mizur.div/2`:

      iex> use Mizur.Infix, only: [/: 2]
      ...> a = MizurTest.Distance.cm(12)
      ...> a / 2
      MizurTest.Distance.cm(6)
  """
  @spec Mizur.typed_value / number :: Mizur.typed_value 
  def a / b do 
    Mizur.div(a, b)
  end

  @doc """
  Infix version of `Mizur.equals/2` :

      iex> use Mizur.Infix, only: [==: 2]
      ...> MizurTest.Distance.cm(100) == MizurTest.Distance.m(1)
      true
  """
  @spec Mizur.typed_value == Mizur.typed_value :: boolean 
  def a == b do 
    Mizur.equals(a, b)
  end

  @doc """
  Infix version of `not Mizur.equals/2` :

      iex> use Mizur.Infix, only: [!=: 2]
      ...> MizurTest.Distance.cm(100) != MizurTest.Distance.m(2)
      true
  """
  @spec Mizur.typed_value != Mizur.typed_value :: boolean 
  def a != b do 
    not Mizur.equals(a, b)
  end

  @doc """
  Infix version of `Mizur.strict_equals/2` :

      iex> use Mizur.Infix, only: [===: 2]
      ...> MizurTest.Distance.cm(100) == MizurTest.Distance.cm(100)
      true
  """
  @spec Mizur.typed_value === Mizur.typed_value :: boolean 
  def a === b do 
    Mizur.strict_equals(a, b)
  end

  @doc """
  Infix version of `not Mizur.strict_equals/2` :

      iex> use Mizur.Infix, only: [!==: 2]
      ...> MizurTest.Distance.cm(100) !== MizurTest.Distance.m(100)
      true
  """
  @spec Mizur.typed_value !== Mizur.typed_value :: boolean 
  def a !== b do 
    not Mizur.strict_equals(a, b)
  end

  @doc """
  Infix version of `Mizur.compare/2 == :gt` :

      iex> use Mizur.Infix, only: [>: 2]
      ...> MizurTest.Distance.cm(100) > MizurTest.Distance.m(0.9)
      true
  """
  @spec Mizur.typed_value > Mizur.typed_value :: boolean 
  def a > b do 
    Kernel.==(Mizur.compare(a, with: b), :gt)
  end

  @doc """
  Infix version of `Mizur.compare/2 == :lt` :

      iex> use Mizur.Infix, only: [<: 2]
      ...> MizurTest.Distance.cm(100) < MizurTest.Distance.m(11)
      true
  """
  @spec Mizur.typed_value < Mizur.typed_value :: boolean 
  def a < b do 
    Kernel.==(Mizur.compare(a, with: b), :lt)
  end

  @doc """
  Infix version of `Mizur.compare/2 == :lt || :eq` :

      iex> use Mizur.Infix, only: [<=: 2]
      ...> MizurTest.Distance.cm(100) <= MizurTest.Distance.m(1)
      true
  """
  @spec Mizur.typed_value <= Mizur.typed_value :: boolean 
  def a <= b do 
    x = Mizur.compare(a, with: b)
    Kernel.==(x, :eq) || Kernel.==(x, :lt)
  end

  @doc """
  Infix version of `Mizur.compare/2 == :gt || :eq` :

      iex> use Mizur.Infix, only: [>=: 2]
      ...> MizurTest.Distance.cm(100) >= MizurTest.Distance.m(1)
      true
  """
  @spec Mizur.typed_value >= Mizur.typed_value :: boolean 
  def a >= b do 
    x = Mizur.compare(a, with: b)
    Kernel.==(x, :eq) || Kernel.==(x, :gt)
  end


  @doc """
  Infix version of `Mizur.Range.new/2`. 

      iex> use Mizur.Infix, only: [..: 2]
      ...> MizurTest.Distance.cm(1) .. MizurTest.Distance.m(1)
      Mizur.Range.new(MizurTest.Distance.cm(1), MizurTest.Distance.cm(100))
  """
  @spec Mizur.typed_value .. Mizur.typed_value :: Mizur.Range.range
  def a .. b do 
    Mizur.Range.new(a, b)
  end
  


  @doc """
  Helper to build `typed_value`

      iex> use Mizur.Infix, only: [in: 2]
      ...> a = MizurTest.Distance.cm(120)
      ...> {a in MizurTest.Distance.m, 12 in MizurTest.Distance.km}
      {MizurTest.Distance.m(1.2), MizurTest.Distance.km(12)}
  """
  @spec (Mizur.typed_value | number) in Mizur.metric_type :: Mizur.typed_value
  def a in t do 
    case a do 
      {{_, _, _, _, _}, _}  -> Mizur.from(a, to: t)
      a when is_number(a)   -> {t, Kernel.*(a, 1.0)}
      _ -> raise RuntimeError, message: "#{t} is incomprehensible"
    end
  end
  

end