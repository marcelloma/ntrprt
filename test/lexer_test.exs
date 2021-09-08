defmodule LexerTest do
  use ExUnit.Case

  test "lexes string into tokens" do
    assert [{:id, "abc", %{}}] = lex("abc")

    assert [
             {:id, "abc", %{}},
             {:=, %{}},
             {:num, 1.0, %{}},
             {:+, %{}},
             {:num, 2.0, %{}}
           ] = lex("abc=1+2")

    assert [
             {:id, "a", %{}},
             {:=, %{}},
             {:num, 1.0, %{}},
             {:";", %{}},
             {:id, "b", %{}},
             {:=, %{}},
             {:id, "a", %{}},
             {:+, %{}},
             {:num, 2.0, %{}}
           ] = lex("a=1; b=a+2")

    assert [
             {:id, "a", %{}},
             {:-, %{}},
             {:id, "b", %{}},
             {:";", %{}},
             {:fn, %{}},
             {:->, %{}},
             {:"(", %{}},
             {:id, "a", %{}},
             {:",", %{}},
             {:id, "b", %{}},
             {:")", %{}},
             {:"{", %{}},
             {:id, "a", %{}},
             {:"}", %{}}
           ] = lex("a-b; fn ->(a, b) { a }")

    assert [
             {:id, "a", %{column: 0, line: 0}},
             {:-, %{column: 1, line: 0}},
             {:id, "b", %{column: 2, line: 0}},
             {:";", %{column: 3, line: 0}},
             {:"\n", %{column: 4, line: 0}},
             {:fn, %{column: 0, line: 1}},
             {:->, %{column: 3, line: 1}},
             {:"(", %{column: 5, line: 1}},
             {:id, "a", %{column: 6, line: 1}},
             {:",", %{column: 7, line: 1}},
             {:id, "b", %{column: 9, line: 1}},
             {:")", %{column: 10, line: 1}},
             {:"{", %{column: 12, line: 1}},
             {:id, "a", %{column: 14, line: 1}},
             {:"}", %{column: 16, line: 1}},
             {:"\n", %{column: 17, line: 1}}
           ] =
             lex("""
             a-b;
             fn ->(a, b) { a }
             """)
  end

  defp lex(str) do
    str
    |> Ntrprt.Lexer.lex()
  end
end
