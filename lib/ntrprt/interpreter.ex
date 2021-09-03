defmodule Ntrprt.Interpreter do
  def interpret([operator, left_ast, right_ast]) when operator in [:+, :-, :*, :/] do
    with left <- interpret(left_ast),
         right <- interpret(right_ast) do
      run_binary(operator, left, right)
    end
  end

  def interpret([:number, value]), do: value

  defp run_binary(:+, left, right), do: left + right
  defp run_binary(:-, left, right), do: left - right
  defp run_binary(:*, left, right), do: left * right
  defp run_binary(:/, left, right), do: left / right
end
