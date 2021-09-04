defmodule LexerTest do
  use ExUnit.Case

  test "lexes string into tokens" do
    assert lex("abc") == [{:token, :identifier, "abc"}]

    assert lex("abc=1+2") == [
             {:token, :identifier, "abc"},
             {:token, :=},
             {:token, :number, 1},
             {:token, :+},
             {:token, :number, 2}
           ]

    assert lex("a=1; b=a+2") == [
             {:token, :identifier, "a"},
             {:token, :=},
             {:token, :number, 1},
             {:token, :semi},
             {:token, :identifier, "b"},
             {:token, :=},
             {:token, :identifier, "a"},
             {:token, :+},
             {:token, :number, 2}
           ]
  end

  defp lex(str) do
    str
    |> Ntrprt.Lexer.lex()
  end
end
