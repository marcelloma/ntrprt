defmodule LexerTest do
  use ExUnit.Case

  test "lexes string into tokens" do
    assert [{:identifier, "abc", %{}}] = lex("abc")

    assert [
             {:identifier, "abc", %{}},
             {:=, %{}},
             {:number, 1.0, %{}},
             {:+, %{}},
             {:number, 2.0, %{}}
           ] = lex("abc=1+2")

    assert [
             {:identifier, "a", %{}},
             {:=, %{}},
             {:number, 1.0, %{}},
             {:";", %{}},
             {:identifier, "b", %{}},
             {:=, %{}},
             {:identifier, "a", %{}},
             {:+, %{}},
             {:number, 2.0, %{}}
           ] = lex("a=1; b=a+2")

    assert [
             {:identifier, "a", %{}},
             {:-, %{}},
             {:identifier, "b", %{}},
             {:";", %{}},
             {:fn, %{}},
             {:->, %{}},
             {:"(", %{}},
             {:identifier, "a", %{}},
             {:",", %{}},
             {:identifier, "b", %{}},
             {:")", %{}},
             {:"{", %{}},
             {:identifier, "a", %{}},
             {:"}", %{}}
           ] = lex("a-b; fn ->(a, b) { a }")

    IO.inspect(
      lex("""
      a-b;
      fn ->(a, b) { a }
      """)
    )
  end

  defp lex(str) do
    str
    |> Ntrprt.Lexer.lex()
  end
end
