defmodule LexerTest do
  use ExUnit.Case

  test "lexes string into tokens" do
    assert [{:id, "abc", %{}}] = lex("abc")

    assert [
             {:id, "abc", %{}},
             {:=, %{}},
             {:integer, 1, %{}},
             {:+, %{}},
             {:integer, 2, %{}}
           ] = lex("abc=1+2")

    assert [
             {:id, "a", %{}},
             {:=, %{}},
             {:integer, 1, %{}},
             {:";", %{}},
             {:id, "b", %{}},
             {:=, %{}},
             {:id, "a", %{}},
             {:+, %{}},
             {:integer, 2, %{}}
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

    assert [
             {:str, "abc", %{column: 0, line: 0}}
           ] = lex("\"abc\"")

    assert [
             {:str, "a\"bc", %{column: 0, line: 0}}
           ] = lex("\"a\\\"bc\"")

    assert [
             {:str, "a\"b\"c", %{column: 0, line: 0}}
           ] = lex("\"a\\\"b\\\"c\"")

    assert [
             {:str, "a\"b\"c\"d\"e\"f", %{column: 0, line: 0}}
           ] = lex("\"a\\\"b\\\"c\\\"d\\\"e\\\"f\"")

    assert [
             {:str, "a\"bc", %{column: 0, line: 0}}
           ] = lex("\"a\\\"bc\"")

    assert [
             {:float, 1.2, %{column: 0, line: 0}}
           ] = lex("1.2")

    assert [{true, %{column: 0, line: 0}}] = lex("true")
    assert [{false, %{column: 0, line: 0}}] = lex("false")

    assert [{:!, %{column: 0, line: 0}}, {false, %{column: 1, line: 0}}] = lex("!false")
  end

  defp lex(str) do
    str
    |> Ntrprt.Lexer.lex()
  end
end
