defmodule ParserTest do
  use ExUnit.Case

  test "parses tokens into ast" do
    assert [[:num, 2.0]] = parse("2")
    assert [[:+, [[:num, 2.0], [:num, 2.0]]]] = parse("2+2")
    assert [[:-, [[:num, 2.0], [:num, 1.0]]]] = parse("2-1")
    assert [[:+, [[:*, [[:num, 2.0], [:num, 1.0]]], [:num, 3.0]]]] = parse("2*1+3")
    assert [[:+, [[:*, [[:num, 2.0], [:num, 1.0]]], [:num, 3.0]]]] = parse("2*1+3")
    assert [[:*, [[:-, [[:num, 2.0]]], [:num, 2.0]]]] = parse("-2*2")
    assert [[:=, [[:id, "x"], [:num, 300.0]]]] = parse("x=300")

    assert [
             [:=, [[:id, "x"], [:num, 300.0]]],
             [:=, [[:id, "y"], [:num, 400.0]]]
           ] = parse("x=300;y=400")

    assert [[:=, [[:id, "abc"], [:*, [[:-, [[:num, 2.0]]], [:num, 2.0]]]]]] = parse("abc=-2*2")

    assert [
             [:=, [[:id, "a"], [:num, 1.0]]],
             [:=, [[:id, "b"], [:+, [[:id, "a"], [:num, 2.0]]]]]
           ] = parse("a=1; b=a+2")

    assert [
             [
               :=,
               [
                 [:id, "inc"],
                 [:fn, [[[:id, "a"]], [[:+, [[:id, "a"], [:num, 1.0]]]]]]
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
             [:=, [[:id, "inc"], [:fn, [[[:id, "x"]], [[:+, [[:id, "x"], [:num, 1.0]]]]]]]],
             [:call, [[:id, "inc"], [[:num, 3.0]]]]
           ] =
             parse("""
             inc = fn ->(x) x + 1
             inc(3)
             """)
  end

  defp parse(str) do
    str
    |> Ntrprt.Lexer.lex()
    |> Ntrprt.Parser.parse()
    |> elem(1)
  end
end
