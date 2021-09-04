defmodule Ntrprt.Interpreter do
  def interpret(asts) do
    interpret(asts, %{})
  end

  def interpret([:compound_statement, [statement_ast]], scope) do
    with {value, scope} <- interpret(statement_ast, scope) do
      {value, scope}
    end
  end

  def interpret([:compound_statement, [statement_ast | statement_asts]], scope) do
    with {_, scope} <- interpret(statement_ast, scope) do
      interpret([:compound_statement, statement_asts], scope)
    end
  end

  def interpret([:statement, value_ast], scope) do
    with {value, scope} <- interpret(value_ast, scope) do
      {value, scope}
    end
  end

  def interpret([operator, value_ast], scope) when operator in [:+, :-] do
    with {value, scope} <- interpret(value_ast, scope) do
      {run_unary(operator, value), scope}
    end
  end

  def interpret([operator, left_ast, right_ast], scope) when operator in [:+, :-, :*, :/] do
    with {left, scope} <- interpret(left_ast, scope),
         {right, scope} <- interpret(right_ast, scope) do
      {run_binary(operator, left, right), scope}
    end
  end

  def interpret([:assignment_statement, [:variable, identifier], value_ast], scope) do
    with {value, scope} <- interpret(value_ast, scope) do
      scope = Map.put(scope, identifier, value)
      {value, scope}
    end
  end

  def interpret([:number, value], scope), do: {value, scope}
  def interpret([:variable, value], scope), do: {Map.get(scope, value), scope}

  defp run_unary(:+, value), do: +value
  defp run_unary(:-, value), do: -value

  defp run_binary(:+, left, right), do: left + right
  defp run_binary(:-, left, right), do: left - right
  defp run_binary(:*, left, right), do: left * right
  defp run_binary(:/, left, right), do: left / right
end
