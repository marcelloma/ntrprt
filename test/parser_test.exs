defmodule ParserTest do
  use ExUnit.Case

  test "parses tokens into ast" do
    assert parse("2") == [:number, 2]
    assert parse("2+2") == [:+, [:number, 2], [:number, 2]]
    assert parse("2-1") == [:-, [:number, 2], [:number, 1]]
    assert parse("2*(1+3)") == [:*, [:number, 2], [:+, [:number, 1], [:number, 3]]]
    assert parse("2*1+3") == [:+, [:*, [:number, 2], [:number, 1]], [:number, 3]]
    assert parse("2+1*3") == [:+, [:number, 2], [:*, [:number, 1], [:number, 3]]]
  end

  defp parse(str) do
    str
    |> Ntrprt.Lexer.lex()
    |> Ntrprt.Parser.parse()
  end
end
