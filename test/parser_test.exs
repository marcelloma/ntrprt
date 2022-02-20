defmodule ParserTest do
  use ExUnit.Case

  test "parses tokens into ast" do
    assert [[:integer, 2]] = parse("2")
    assert [[:+, [[:integer, 2], [:integer, 2]]]] = parse("2+2")
    assert [[:-, [[:integer, 2], [:integer, 1]]]] = parse("2-1")
    assert [[:+, [[:*, [[:integer, 2], [:integer, 1]]], [:integer, 3]]]] = parse("2*1+3")
    assert [[:+, [[:*, [[:integer, 2], [:integer, 1]]], [:integer, 3]]]] = parse("2*1+3")
    assert [[:*, [[:-, [[:integer, 2]]], [:integer, 2]]]] = parse("-2*2")
    assert [[:=, [[:id, "x"], [:integer, 300]]]] = parse("x=300")

    assert [
             [:=, [[:id, "x"], [:integer, 300]]],
             [:=, [[:id, "y"], [:integer, 400]]]
           ] = parse("x=300;y=400")

    assert [[:=, [[:id, "abc"], [:*, [[:-, [[:integer, 2]]], [:integer, 2]]]]]] =
             parse("abc=-2*2")

    assert [
             [:=, [[:id, "a"], [:integer, 1]]],
             [:=, [[:id, "b"], [:+, [[:id, "a"], [:integer, 2]]]]]
           ] = parse("a=1; b=a+2")

    assert [
             [
               :=,
               [
                 [:id, "inc"],
                 [:fn, [[[:id, "a"]], [[:+, [[:id, "a"], [:integer, 1]]]]]]
               ]
             ]
           ] = parse("inc = fn ->(a) a + 1")

    assert [
             [
               :=,
               [
                 [:id, "sum"],
                 [
                   :fn,
                   [
                     [[:id, "a"]],
                     [[:fn, [[[:id, "b"]], [[:+, [[:id, "a"], [:id, "b"]]]]]]]
                   ]
                 ]
               ]
             ]
           ] = parse("sum = fn ->(a) { fn ->(b) { a + b } }")

    assert [
             [:=, [[:id, "inc"], [:fn, [[[:id, "x"]], [[:+, [[:id, "x"], [:integer, 1]]]]]]]],
             [:call, [[:id, "inc"], [[:integer, 3]]]]
           ] =
             parse("""
             inc = fn ->(x) x + 1
             inc(3)
             """)

    assert [[:=, [[:id, "a"], [true]]], [:id, "a"]] = parse("a = true; a")
    assert [[:=, [[:id, "a"], [false]]], [:id, "a"]] = parse("a = false; a")
  end

  defp parse(str) do
    str
    |> Ntrprt.Lexer.lex()
    |> Ntrprt.Parser.parse()
    |> elem(1)
  end
end
