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

    assert lex("a-b; fn ->(a, b) { a }") == [
             {:token, :identifier, "a"},
             {:token, :-},
             {:token, :identifier, "b"},
             {:token, :semi},
             {:token, :fn},
             {:token, :->},
             {:token, :lparen},
             {:token, :identifier, "a"},
             {:token, :comma},
             {:token, :identifier, "b"},
             {:token, :rparen},
             {:token, :lbrace},
             {:token, :identifier, "a"},
             {:token, :rbrace}
           ]
  end

  defp lex(str) do
    str
    |> Ntrprt.Lexer.lex()
  end
end
