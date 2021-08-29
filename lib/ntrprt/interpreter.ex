defmodule Ntrprt.Interpreter do
  def interpret(tokens) do
    tokens
    |> root()
    |> List.first()
  end

  # root() -> term() + | - term()*
  def root(tokens) do
    [left | tokens] = term(tokens)

    case tokens do
      [{:token, :+} | tokens] ->
        [right | tokens] = term(tokens)
        root([left + right | tokens])

      [{:token, :-} | tokens] ->
        [right | tokens] = term(tokens)
        root([left - right | tokens])

      _ ->
        [left | tokens]
    end
  end

  # term() -> el() * | / el()*
  def term(tokens) do
    [left | tokens] = el(tokens)

    case tokens do
      [{:token, :*} | tokens] ->
        [right | tokens] = el(tokens)
        term([left * right | tokens])

      [{:token, :/} | tokens] ->
        [right | tokens] = el(tokens)
        term([left / right | tokens])

      _ ->
        [left | tokens]
    end
  end

  # el() -> number | ( root )
  def el(tokens) do
    case tokens do
      [{:token, :number, value} | tokens] ->
        [value | tokens]

      [{:token, :lparen} | tokens] ->
        [right | tokens] = root(tokens)
        [{:token, :rparen} | tokens] = tokens
        [right | tokens]

      [value | tokens] ->
        [value | tokens]
    end
  end
end
