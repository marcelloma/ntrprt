defmodule ParserTest do
  use ExUnit.Case

  test "parses tokens into ast" do
    assert [[:integer, 2, %{column: 0, line: 0}]] = parse("2")
    assert [[:+, [[:integer, 2, %{column: 0, line: 0}], [:integer, 2, %{column: 2, line: 0}]], %{column: 1, line: 0}]] = parse("2+2")
    assert [[:-, [[:integer, 2, %{column: 0, line: 0}], [:integer, 1, %{column: 2, line: 0}]], %{column: 1, line: 0}]] = parse("2-1")
    assert [[:+, [[:*, [[:integer, 2, %{column: 0, line: 0}], [:integer, 1, %{column: 2, line: 0}]], %{column: 1, line: 0}], [:integer, 3, %{column: 4, line: 0}]], %{column: 3, line: 0}]] = parse("2*1+3")
    assert [[:+, [[:*, [[:integer, 2, %{column: 0, line: 0}], [:integer, 1, %{column: 2, line: 0}]], %{column: 1, line: 0}], [:integer, 3, %{column: 4, line: 0}]], %{column: 3, line: 0}]] = parse("2*1+3")
    assert [[:*, [[:-, [[:integer, 2, %{column: 1, line: 0}]], %{column: 0, line: 0}], [:integer, 2, %{column: 3, line: 0}]], %{column: 2, line: 0}]] = parse("-2*2")
    assert [[:=, [[:id, "x", %{column: 0, line: 0}], [:integer, 300, %{column: 2, line: 0}]], %{column: 1, line: 0}]] = parse("x=300")

    assert [
      [:=, [[:id, "x", %{column: 0, line: 0}], [:integer, 300, %{column: 2, line: 0}]], %{column: 1, line: 0}],
      [:=, [[:id, "y", %{column: 6, line: 0}], [:integer, 400, %{column: 8, line: 0}]], %{column: 7, line: 0}]
           ] = parse("x=300;y=400")

    assert [
      [
        :=,
        [
          [:id, "abc", %{column: 0, line: 0}],
          [:*, [[:-, [[:integer, 2, %{column: 5, line: 0}]], %{column: 4, line: 0}], [:integer, 2, %{column: 7, line: 0}]], %{column: 6, line: 0}]
        ],
        %{column: 3, line: 0}
      ]
    ] =
             parse("abc=-2*2")

    assert [
      [:=, [[:id, "a", %{column: 0, line: 0}], [:integer, 1, %{column: 2, line: 0}]], %{column: 1, line: 0}],
      [:=, [[:id, "b", %{column: 5, line: 0}], [:+, [[:id, "a", %{column: 7, line: 0}], [:integer, 2, %{column: 9, line: 0}]], %{column: 8, line: 0}]], %{column: 6, line: 0}]
    ] = parse("a=1; b=a+2")

    assert [
      [
        :=,
        [
          [:id, "inc", %{column: 0, line: 0}],
          [:fn, [[[:id, "a", %{column: 12, line: 0}]], [[:+, [[:id, "a", %{column: 15, line: 0}], [:integer, 1, %{column: 19, line: 0}]], %{column: 17, line: 0}]]]]
        ],
        %{column: 4, line: 0}
      ]
    ] = parse("inc = fn ->(a) a + 1")

    assert [
      [
        :=,
        [
          [:id, "abc", %{column: 0, line: 0}],
          [:*, [[:-, [[:integer, 2, %{column: 5, line: 0}]], %{column: 4, line: 0}], [:integer, 2, %{column: 7, line: 0}]], %{column: 6, line: 0}]
        ],
        %{column: 3, line: 0}
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

    assert [[:if, [[true], [[:integer, 1]], [[:integer, 2]]]]] =
             parse("if (true) { 1 } else { 2 }")

    assert [[:if, [[true], [[:integer, 1]], []]]] = parse("if (true) { 1 }")
  end

  defp parse(str) do
    str
    |> Ntrprt.Lexer.lex()
    |> Ntrprt.Parser.parse()
    |> elem(1)
  end
end
