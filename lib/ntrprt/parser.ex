defmodule Ntrprt.Parser do
  def parse(tokens) do
    tokens
    |> compound_statement()
    |> List.first()
  end

  def compound_statement([{:token, :newline} | tokens]), do: compound_statement(tokens, [])
  def compound_statement(tokens), do: compound_statement(tokens, [])

  def compound_statement(tokens, statements) do
    [new_statement | tokens] = statement(tokens)

    statements = [new_statement | statements]

    case tokens do
      [{:token, :semi} | tokens] ->
        compound_statement(tokens, statements)

      [{:token, :newline} | tokens] ->
        compound_statement(tokens, statements)

      _ ->
        [statements |> Enum.reverse() | tokens]
    end
  end

  def statement(tokens) do
    case tokens do
      [{:token, :identifier, _}, {:token, :=} | _] ->
        assignment_statement(tokens)

      [{:token, :identifier, _}, {:token, :lparen} | _] ->
        function_call(tokens)

      _ ->
        expression(tokens)
    end
  end

  def assignment_statement(tokens) do
    [left | tokens] = variable(tokens)
    [{:token, :=} | tokens] = tokens
    [right | tokens] = expression(tokens)
    [[:assignment_statement, left, right] | tokens]
  end

  def function_call(tokens) do
    [{:token, :identifier, identifier} | tokens] = tokens
    [{:token, :lparen} | tokens] = tokens
    [params | tokens] = function_call_arguments(tokens)
    [{:token, :rparen} | tokens] = tokens

    case tokens do
      [{:token, :newline} | tokens] ->
        [[:call, identifier, params] | tokens]

      _ ->
        [[:call, identifier, params] | tokens]
    end
  end

  def function_call_arguments(tokens, arguments \\ [])
  def function_call_arguments([{:token, :rparen} | tokens], arguments), do: [arguments | tokens]

  def function_call_arguments(tokens, arguments) do
    [argument | tokens] = statement(tokens)

    case tokens do
      [{:token, :comma} | tokens] ->
        function_call_arguments(tokens, [argument | arguments])

      _ ->
        [[argument | arguments] | tokens]
    end
  end

  def function(tokens) do
    [{:token, :lparen} | tokens] = tokens
    [params | tokens] = function_parameters(tokens)
    [{:token, :rparen} | tokens] = tokens

    case tokens do
      [{:token, :lbrace} | tokens] ->
        [body | tokens] = compound_statement(tokens)
        [{:token, :rbrace} | tokens] = tokens
        [[:function, params, body] | tokens]

      _ ->
        [body | tokens] = statement(tokens)
        [[:function, params, [body]] | tokens]
    end
  end

  def function_parameters(tokens, parameters \\ []) do
    case tokens do
      [{:token, :comma} | tokens] ->
        function_parameters(tokens, parameters)

      [{:token, :identifier, identifier} | tokens] ->
        [[identifier | parameters] | tokens]

      _ ->
        [[] | tokens]
    end
  end

  def expression(tokens) do
    [left | tokens] = term(tokens)

    case tokens do
      [{:token, :+} | tokens] ->
        [right | tokens] = term(tokens)
        expression([[:+, left, right] | tokens])

      [{:token, :-} | tokens] ->
        [right | tokens] = term(tokens)
        expression([[:-, left, right] | tokens])

      [{:token, :->} | tokens] ->
        [value | tokens] = function(tokens)
        [value | tokens]

      _ ->
        [left | tokens]
    end
  end

  # term : factor | (('*' | '/') factor)*
  def term(tokens) do
    [left | tokens] = factor(tokens)

    case tokens do
      [{:token, :*} | tokens] ->
        [right | tokens] = factor(tokens)
        term([[:*, left, right] | tokens])

      [{:token, :/} | tokens] ->
        [right | tokens] = factor(tokens)
        term([[:/, left, right] | tokens])

      _ ->
        [left | tokens]
    end
  end

  def factor(tokens) do
    case tokens do
      [{:token, :+} | tokens] ->
        [left | tokens] = factor(tokens)
        [[:+, left] | tokens]

      [{:token, :-} | tokens] ->
        [left | tokens] = factor(tokens)
        [[:-, left] | tokens]

      [{:token, :number, value} | tokens] ->
        [[:number, value] | tokens]

      [{:token, :lparen} | tokens] ->
        [right | tokens] = expression(tokens)
        [{:token, :rparen} | tokens] = tokens
        [right | tokens]

      _ ->
        variable(tokens)
    end
  end

  def variable(tokens) do
    case tokens do
      [{:token, :identifier, identifier} | tokens] ->
        [[:variable, identifier] | tokens]

      _ ->
        tokens
    end
  end
end
