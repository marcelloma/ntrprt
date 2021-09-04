defmodule Ntrprt.Parser do
  def parse(tokens) do
    tokens
    |> compound_statement()
    |> List.first()
  end

  # compound_statement : statement | statement ('semi' | 'newline') compound_statement
  def compound_statement(tokens), do: compound_statement(tokens, [])

  def compound_statement(tokens, statements) do
    [new_statement | tokens] = statement(tokens)

    statements = [new_statement | statements]

    case tokens do
      [{:token, :semi} | tokens] ->
        compound_statement(tokens, statements)

      [{:token, :newline} | tokens] ->
        compound_statement(tokens, statements)

      [] ->
        [[:compound_statement, statements |> Enum.reverse()]]

      _ ->
        raise "statement must end with semicolon or newline"
    end
  end

  # statement : assignment_statement | expression
  def statement(tokens) do
    case tokens do
      [{:token, :identifier, _} | _] ->
        [value | tokens] = assignment_statement(tokens)
        [[:statement, value] | tokens]

      _ ->
        [value | tokens] = expression(tokens)
        [[:statement, value] | tokens]
    end
  end

  # assignment_statement : variable '=' expression
  def assignment_statement(tokens) do
    [left | tokens] = variable(tokens)

    case tokens do
      [{:token, :=} | tokens] ->
        [right | tokens] = expression(tokens)
        [[:assignment_statement, left, right] | tokens]

      _ ->
        tokens
    end
  end

  # expression : term | (('+' | '-') term)*
  def expression(tokens) do
    [left | tokens] = term(tokens)

    case tokens do
      [{:token, :+} | tokens] ->
        [right | tokens] = term(tokens)
        expression([[:+, left, right] | tokens])

      [{:token, :-} | tokens] ->
        [right | tokens] = term(tokens)
        expression([[:-, left, right] | tokens])

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

  # factor : '+' factor
  #        | '-' factor
  #        | 'number'
  #        | 'lparen' expression 'rparen'
  #        | variable
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

  # variable : 'identifier'
  def variable(tokens) do
    case tokens do
      [{:token, :identifier, identifier} | tokens] ->
        [[:variable, identifier] | tokens]

      _ ->
        tokens
    end
  end
end
