defmodule ParserTest do
  use ExUnit.Case

  test "parses tokens into ast" do
    assert parse("2") == [:compound_statement, [[:statement, [:number, 2]]]]
    assert parse("2+2") == [:compound_statement, [[:statement, [:+, [:number, 2], [:number, 2]]]]]
    assert parse("2-1") == [:compound_statement, [[:statement, [:-, [:number, 2], [:number, 1]]]]]

    assert parse("2*(1+3)") == [
             :compound_statement,
             [[:statement, [:*, [:number, 2], [:+, [:number, 1], [:number, 3]]]]]
           ]

    assert parse("2*1+3") == [
             :compound_statement,
             [[:statement, [:+, [:*, [:number, 2], [:number, 1]], [:number, 3]]]]
           ]

    assert parse("2+1*3") == [
             :compound_statement,
             [[:statement, [:+, [:number, 2], [:*, [:number, 1], [:number, 3]]]]]
           ]

    assert parse("-2*2") == [
             :compound_statement,
             [[:statement, [:*, [:-, [:number, 2]], [:number, 2]]]]
           ]

    assert parse("abc=-2*2") == [
             :compound_statement,
             [
               [
                 :statement,
                 [
                   :assignment_statement,
                   [:variable, "abc"],
                   [:*, [:-, [:number, 2]], [:number, 2]]
                 ]
               ]
             ]
           ]

    assert parse("a=1; b=a+2") == [
             :compound_statement,
             [
               [:statement, [:assignment_statement, [:variable, "a"], [:number, 1]]],
               [
                 :statement,
                 [:assignment_statement, [:variable, "b"], [:+, [:variable, "a"], [:number, 2]]]
               ]
             ]
           ]

    assert_raise RuntimeError, "statement must end with semicolon or newline", fn ->
      parse("a=1+2; b=a+4 c=a+b")
    end
  end

  defp parse(str) do
    str
    |> Ntrprt.Lexer.lex()
    |> Ntrprt.Parser.parse()
  end
end
