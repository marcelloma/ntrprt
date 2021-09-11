defmodule Ntrprt.Interpreter do
  def interpret(asts) do
    interpret(asts, %{})
  end

  def interpret(
        [:=, [[:id, identifier], [:fn | _] = function_ast]],
        scope
      ) do
    scope = Map.put(scope, identifier, function_ast)
    {identifier, scope}
  end

  def interpret([:fn | _] = function_ast, scope) do
    {function_ast, scope}
  end

  def interpret([:=, [[:id, identifier], value_ast]], scope) do
    with {value, scope} <- interpret(value_ast, scope) do
      scope = Map.put(scope, identifier, value)
      {value, scope}
    end
  end

  def interpret([:call, [[:id, identifier], argument_asts]], scope) do
    interpret([:call, [[:id, identifier], argument_asts], false], scope)
  end

  def interpret([:call, [[:id, identifier], argument_asts], nested_call], scope) do
    with [:fn, [formal_arguments, body_ast]] <- Map.get(scope, identifier),
         formal_arguments <- Enum.map(formal_arguments, &Enum.at(&1, 1)),
         argument_values <-
           argument_asts |> Enum.map(&interpret(&1, scope)) |> Enum.map(&elem(&1, 0)),
         arguments <- Enum.zip(formal_arguments, argument_values) |> Enum.into(%{}),
         nested_scope <- Map.merge(scope, arguments),
         {value, _} <- interpret(body_ast, nested_scope) do
      {value, (if nested_call, do: nested_scope, else: scope)}
    end
  end

  def interpret([:call, [[:call|_] = other_call, argument_asts]], scope) do
    with {[:fn, [formal_arguments, body_ast]], scope} <- interpret(other_call ++ [true], scope),
         formal_arguments <- Enum.map(formal_arguments, &Enum.at(&1, 1)),
         argument_values <-
           argument_asts |> Enum.map(&interpret(&1, scope)) |> Enum.map(&elem(&1, 0)),
         arguments <- Enum.zip(formal_arguments, argument_values) |> Enum.into(%{}),
         nested_scope <- Map.merge(scope, arguments),
         {value, _} <- interpret(body_ast, nested_scope) do
      {value, scope}
    end
  end

  def interpret([:num, value], scope), do: {value, scope}
  def interpret([:id, value], scope), do: {Map.get(scope, value), scope}

  def interpret([operator, [value_ast]], scope) when operator in [:+, :-] do
    with {value, scope} <- interpret(value_ast, scope) do
      {run_unary(operator, value), scope}
    end
  end

  def interpret([operator, [left_ast, right_ast]], scope) when operator in [:+, :-, :*, :/] do
    with {left, scope} <- interpret(left_ast, scope),
         {right, scope} <- interpret(right_ast, scope) do
      {run_binary(operator, left, right), scope}
    end
  end

  def interpret([statement_ast], scope) do
    with {value, scope} <- interpret(statement_ast, scope) do
      {value, scope}
    end
  end

  def interpret([statement_ast | statement_asts], scope) do
    with {_, scope} <- interpret(statement_ast, scope) do
      interpret([statement_asts], scope)
    end
  end

  defp run_unary(:+, value), do: +value
  defp run_unary(:-, value), do: -value

  defp run_binary(:+, left, right), do: left + right
  defp run_binary(:-, left, right), do: left - right
  defp run_binary(:*, left, right), do: left * right
  defp run_binary(:/, left, right), do: left / right
end
