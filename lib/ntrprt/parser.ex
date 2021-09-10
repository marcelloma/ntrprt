defmodule Ntrprt.Parser do
  import Ntrprt.Combinator

  def parse(tokens) do
    block().(tokens)
  end

  def match(token) do
    fn
      [{^token, %{}} | rest] -> {:ok, token, rest}
      _ -> {:error, ""}
    end
  end

  def skip(token) do
    fn
      [{^token, %{}} | rest] -> {:ok, nil, rest}
      _ -> {:error, ""}
    end
  end

  def value(token) do
    fn
      [{^token, value, %{}} | rest] -> {:ok, [token, value], rest}
      _ -> {:error, ""}
    end
  end

  def unary_operation(operator, term) do
    sequence([operator, term])
    |> map(fn [left, right] -> [left, [right]] end)
  end

  def binary_operation(operator, term) do
    sequence([
      term,
      one_or_many(sequence([operator, term]))
    ])
    |> map(fn [left, right] -> [left | right] end)
    |> map(fn [left | right] ->
      Enum.reduce(right, left, fn [op, right_argument], left -> [op, [left, right_argument]] end)
    end)
  end

  def debug(parser, label) do
    map(parser, &IO.inspect(&1, label: label))
  end

  def multiplication_or_division() do
    choice([match(:*), match(:/)])
    |> binary_operation(factor())
  end

  def plus_or_minus() do
    choice([match(:+), match(:-)])
    |> binary_operation(term())
  end

  def unary() do
    choice([match(:+), match(:-)])
    |> unary_operation(&factor().(&1))
  end

  def expression() do
    choice([plus_or_minus(), term()])
  end

  def term() do
    choice([multiplication_or_division(), factor()])
  end

  def factor() do
    choice([
      unary(),
      sequence([match(:"("), &expression().(&1), match(:")")]) |> map(&Enum.at(&1, 1)),
      number(),
      identifier()
    ])
  end

  def number() do
    value(:num)
  end

  def identifier() do
    value(:id)
  end

  def block() do
    sequence([
      zero_or_many(match(:"\n")),
      statement_list(),
      zero_or_many(match(:"\n"))
    ])
    |> map(&Enum.at(&1, 1))
  end

  def statement_list() do
    choice([
      one_or_many(
        sequence([
          statement(),
          choice([match(:";"), match(:"\n")]),
          statement()
        ])
        |> map(&List.delete_at(&1, 1))
      )
      |> map(&List.first/1),
      statement()
    ])
  end

  def statement() do
    choice([assignment(), expression()])
  end

  def assignment() do
    sequence([
      identifier(),
      match(:=),
      expression()
    ])
    |> map(fn [left, operator, right] -> [operator, [left, right]] end)
  end
end
