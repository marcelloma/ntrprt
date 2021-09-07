defmodule NtrprtTest do
  use ExUnit.Case

  test "interprets asts" do
    assert interpret("1+2") == {3, %{}}
    assert interpret("2-1") == {1, %{}}
    assert interpret("2+3+10*2") == {25, %{}}
    assert interpret("2") == {2, %{}}
    assert interpret("1+3/3") == {2, %{}}
    assert interpret("2*2*2") == {8, %{}}
    assert interpret("2*(2+2)") == {8, %{}}
    assert interpret("((10+20))") == {30, %{}}
    assert interpret("((10+20)*2)") == {60, %{}}
    assert interpret("2*-1") == {-2, %{}}
    assert interpret("2*--1") == {2, %{}}
    assert interpret("2*---1") == {-2, %{}}
    assert interpret("2*-(-(+2-1))") == {2, %{}}
    assert interpret("5 - - - + - (3 + 4) - +2") == {10, %{}}
    assert interpret("a=1+2") == {3, %{"a" => 3}}
    assert interpret("a=1+2; b=a+4") == {7, %{"a" => 3, "b" => 7}}
    assert interpret("a=1+2\n b=a+4") == {7, %{"a" => 3, "b" => 7}}

    assert {5, %{"inc" => [:function, ["x"], [[:+, [:variable, "x"], [:number, 1]]]]}} =
             interpret("
    inc = fn ->(x) x + 1
    inc(inc(3))
    ")

    assert {3, %{"inc" => [:function, ["x"], [[:+, [:variable, "x"], [:number, 1]]]]}} =
             interpret("
    addcurry = fn ->(x) fn ->(y) x + y
    addcurry(1)(2)
    ")
  end

  defp interpret(str) do
    str
    |> Ntrprt.Lexer.lex()
    |> Ntrprt.Parser.parse()
    |> IO.inspect()
    |> Ntrprt.Interpreter.interpret()
  end
end
