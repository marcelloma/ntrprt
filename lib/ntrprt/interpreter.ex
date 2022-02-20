defmodule Ntrprt.Interpreter do
  alias Ntrprt.Env

  def interpret(asts) do
    interpret(asts, Env.new())
  end

  defp push_env_to_function(env, [:fn, [args, body]]) do
    [:fn, [args, body, env]]
  end

  def interpret(
        [:=, [[:id, identifier], [:fn | _] = function_ast]],
        env
      ) do
    function = push_env_to_function(env, function_ast)
    env = Env.set_variable(env, identifier, function)
    {identifier, env}
  end

  def interpret([:fn | _] = function_ast, env) do
    function = push_env_to_function(env, function_ast)
    {function, env}
  end

  def interpret([:=, [[:id, identifier], value_ast]], env) do
    with {value, env} <- interpret(value_ast, env) do
      env = Env.set_variable(env, identifier, value)
      {value, env}
    end
  end

  def interpret([:call, [[:id, identifier], argument_asts]], env) do
    with [:fn, [formal_arguments, body_ast, local_env]] <- Env.get_variable(env, identifier),
         formal_arguments <- Enum.map(formal_arguments, &Enum.at(&1, 1)),
         argument_values <-
           argument_asts |> Enum.map(&interpret(&1, env)) |> Enum.map(&elem(&1, 0)),
         arguments <- Enum.zip(formal_arguments, argument_values),
         call_env <- Env.push_frame(local_env) |> Env.set_variables(arguments),
         {value, _} <- interpret(body_ast, call_env) do
      {value, env}
    end
  end

  def interpret([:if, [condition_ast, true_ast, false_ast]], env) do
    with {value, true_env} <- interpret(condition_ast, env),
         {value, _} <-
           if(value, do: interpret(true_ast, true_env), else: interpret(false_ast, env)) do
      {value, env}
    end
  end

  def interpret([:call, [[:call | _] = other_call, argument_asts]], env) do
    with {[:fn, [formal_arguments, body_ast, local_env]], env} <- interpret(other_call, env),
         formal_arguments <- Enum.map(formal_arguments, &Enum.at(&1, 1)),
         argument_values <-
           argument_asts |> Enum.map(&interpret(&1, env)) |> Enum.map(&elem(&1, 0)),
         arguments <- Enum.zip(formal_arguments, argument_values),
         call_env <- Env.push_frame(local_env) |> Env.set_variables(arguments),
         {value, _} <- interpret(body_ast, call_env) do
      {value, env}
    end
  end

  def interpret([true], env), do: {true, env}
  def interpret([false], env), do: {false, env}

  def interpret([:integer, value], env), do: {value, env}
  def interpret([:float, value], env), do: {value, env}
  def interpret([:id, identifier], env), do: {Env.get_variable(env, identifier), env}

  def interpret([operator, [value_ast]], env) when operator in [:+, :-, :!] do
    with {value, env} <- interpret(value_ast, env) do
      {run_unary(operator, value), env}
    end
  end

  def interpret([operator, [left_ast, right_ast]], env) when operator in [:+, :-, :*, :/] do
    with {left, env} <- interpret(left_ast, env),
         {right, env} <- interpret(right_ast, env) do
      {run_binary(operator, left, right), env}
    end
  end

  def interpret([statement_ast], env) do
    interpret(statement_ast, env)
  end

  def interpret([statement_ast | statement_asts], env) do
    with {_, env} <- interpret(statement_ast, env) do
      interpret([statement_asts], env)
    end
  end

  defp run_unary(:+, value), do: +value
  defp run_unary(:-, value), do: -value
  defp run_unary(:!, value), do: !value

  defp run_binary(:+, left, right), do: left + right
  defp run_binary(:-, left, right), do: left - right
  defp run_binary(:*, left, right), do: left * right
  defp run_binary(:/, left, right), do: left / right
end
