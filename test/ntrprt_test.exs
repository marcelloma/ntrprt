defmodule NtrprtTest do
  use ExUnit.Case

  test "works" do
    assert interpret("2+3+10*2") == 25
    assert interpret("2") == 2
    assert interpret("2+1") == 3
    assert interpret("1+3/3") == 2
    assert interpret("2*2*2") == 8
    assert interpret("2*(2+2)") == 8
    assert interpret("((10+20))") == 30
    assert interpret("((10+20)*2)") == 60
  end

  defp interpret(str) do
    str
    |> Ntrprt.Lexer.lex()
    |> Ntrprt.Interpreter.interpret()
  end
end
