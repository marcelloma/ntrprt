defmodule ParserTest do
  use ExUnit.Case

  test "parses tokens into ast" do
    assert [[:number, 2]] = parse("2")
    assert [[:+, [:number, 2], [:number, 2]]] = parse("2+2")
    assert [[:-, [:number, 2], [:number, 1]]] = parse("2-1")
    assert [[:*, [:number, 2], [:+, [:number, 1], [:number, 3]]]] = parse("2*(1+3)")
    assert [[:+, [:*, [:number, 2], [:number, 1]], [:number, 3]]] = parse("2*1+3")
    assert [[:*, [:-, [:number, 2]], [:number, 2]]] = parse("-2*2")

    assert [
             [
               :assignment_statement,
               [:variable, "abc"],
               [:*, [:-, [:number, 2]], [:number, 2]]
             ]
           ] = parse("abc=-2*2")

    assert [
             [:assignment_statement, [:variable, "a"], [:number, 1]],
             [:assignment_statement, [:variable, "b"], [:+, [:variable, "a"], [:number, 2]]]
           ] = parse("a=1; b=a+2")

    assert [
             [
               :assignment_statement,
               [:variable, "inc"],
               [:function, ["a"], [[:+, [:variable, "a"], [:number, 1]]]]
             ]
           ] = parse("inc = fn ->(a) a + 1")

    assert [
             [
               :assignment_statement,
               [:variable, "sum"],
               [
                 :function,
                 ["a"],
                 [
                   [
                     :function,
                     ["b"],
                     [[:+, [:variable, "a"], [:variable, "b"]]]
                   ]
                 ]
               ]
             ]
           ] = parse("sum = fn ->(a) { fn ->(b) { a + b } }")

    parse("inc = fn ->(x) x + 1
           inc(3)
           ")
  end

  defp parse(str) do
    str
    |> Ntrprt.Lexer.lex()
    |> Ntrprt.Parser.parse()
  end
end
