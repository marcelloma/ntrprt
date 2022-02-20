defmodule NtrprtTest do
  use ExUnit.Case

  test "interprets asts" do
    assert {3, _} = interpret("1+2")
    assert {1, _} = interpret("2-1")
    assert {25, _} = interpret("2+3+10*2")
    assert {2, _} = interpret("2")
    assert {2.0, _} = interpret("1+3/3")
    assert {8, _} = interpret("2*2*2")
    assert {8, _} = interpret("2*(2+2)")
    assert {30, _} = interpret("((10+20))")
    assert {60, _} = interpret("((10+20)*2)")
    assert {-2, _} = interpret("2*-1")
    assert {2, _} = interpret("2*--1")
    assert {-2, _} = interpret("2*---1")
    assert {2, _} = interpret("2*-(-(+2-1))")
    assert {10, _} = interpret("5 - - - + - (3 + 4) - +2")
    assert {3, _} = interpret("a=1+2")
    assert {7, _} = interpret("a=1+2; b=a+4")
    assert {7, _} = interpret("a=1+2\n b=a+4")

    assert {5, _} = interpret("inc = fn ->(x) x + 1; inc(inc(3))")

    assert {3, _} =
             interpret("""
             addcurry = fn ->(x) fn ->(y) x + y
             addcurry(1)(2)
             """)

    assert {999, _} =
             interpret("""
             k = fn ->(x) fn ->(y) x
             s = fn ->(x) fn ->(y) fn ->(z) x(z)(y(z))
             id = s(k)(k)
             id(999)
             """)

    assert {8, _} =
             interpret("""
             x = 4
             doublex = fn ->() x * 2
             doublex()
             """)

    assert {10, _} =
             interpret("""
             x = 4
             double_x_add_2 = fn ->() {
               y = 2
               z = x * 2 + 2
               z
             }
             double_x_add_2()
             """)
  end

  defp interpret(str) do
    str
    |> Ntrprt.Lexer.lex()
    |> Ntrprt.Parser.parse()
    |> elem(1)
    |> Ntrprt.Interpreter.interpret()
  end
end
