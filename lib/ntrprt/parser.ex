defmodule Ntrprt.Parser do
  import Ntrprt.Combinator

  def parse(tokens) do
    block().(tokens)
  end

  defp block() do
    sequence([
      zero_or_many(match(:"\n")),
      statement_list(),
      zero_or_many(match(:"\n"))
    ])
    |> map(&Enum.at(&1, 1))
  end

  defp statement_list() do
    sequence([
      statement(),
      zero_or_many(
        sequence([
          choice([match(:";"), match(:"\n")]),
          statement()
        ])
        |> map(&Enum.at(&1, 1))
      )
    ])
    |> map(fn [left, right] -> [left | right] end)
  end

  defp statement() do
    fn tokens ->
      choice([assignment(), expression()]).(tokens)
    end
  end

  defp assignment() do
    sequence([
      identifier(),
      match(:=),
      expression()
    ])
    |> map(fn [left, operator, right] -> [operator, [left, right]] end)
  end

  defp expression() do
    fn tokens ->
      # IO.inspect(tokens, label: "here2")
      choice([
        function(),
        function_call(),
        plus_or_minus(),
        term()
      ]).(tokens)
    end
  end

  defp function() do
    sequence([
      # |> debug("fn"),
      match(:fn),
      # |> debug("->"),
      match(:->),
      # |> debug("arg_list"),
      formal_argument_list(),
      choice([
        sequence([match(:"{"), &block().(&1), match(:"}")]) |> map(&Enum.at(&1, 1)),
        wrap(&expression().(&1))
      ])

      # |> debug("body")
    ])
    |> map(fn [_, _, args, body] -> [:fn, [args, body]] end)
  end

  defp formal_argument_list() do
    choice([
      sequence([match(:"("), match(:")")]) |> map(fn _ -> [] end),
      sequence([
        match(:"("),
        identifier(),
        zero_or_many(sequence([match(:","), identifier()])),
        match(:")")
      ])
      |> map(fn [_, left, right, _] -> [left | right] end)
    ])
  end

  defp function_call() do
    sequence([
      # |> debug("id"),
      identifier(),
      one_or_many(argument_list())
    ])
    |> map(fn [left, right] -> [left | right] end)
    |> map(fn [left | right] ->
      Enum.reduce(right, left, fn [right], left -> [:call, [left, [right]]] end)
    end)
  end

  defp argument_list() do
    fn tokens ->
      # IO.inspect(tokens, label: "arg_list")

      choice([
        sequence([match(:"("), match(:")")]) |> map(fn _ -> [] end),
        sequence([
          match(:"("),
          &expression().(&1),
          zero_or_many(sequence([match(:","), identifier()])),
          match(:")")
        ])
        |> map(fn [_, left, right, _] -> [left | right] end)
      ]).(tokens)
    end
  end

  defp plus_or_minus() do
    choice([match(:+), match(:-)])
    |> binary_operation(term())
  end

  defp term() do
    choice([multiplication_or_division(), factor()])
  end

  defp multiplication_or_division() do
    choice([match(:*), match(:/)])
    |> binary_operation(factor())
  end

  defp factor() do
    choice([
      unary(),
      sequence([match(:"("), &expression().(&1), match(:")")]) |> map(&Enum.at(&1, 1)),
      number(),
      identifier()
    ])
  end

  defp unary() do
    choice([match(:+), match(:-)])
    |> unary_operation(&factor().(&1))
  end

  defp match(token) do
    fn
      [{^token, %{}} | rest] -> {:ok, token, rest}
      _ -> {:error, ""}
    end
  end

  defp value(token) do
    fn
      [{^token, value, %{}} | rest] -> {:ok, [token, value], rest}
      _ -> {:error, ""}
    end
  end

  defp unary_operation(operator, term) do
    sequence([operator, term])
    |> map(fn [left, right] -> [left, [right]] end)
  end

  defp binary_operation(operator, term) do
    sequence([
      term,
      one_or_many(sequence([operator, term]))
    ])
    |> map(fn [left, right] -> [left | right] end)
    |> map(fn [left | right] ->
      Enum.reduce(right, left, fn [op, right_argument], left -> [op, [left, right_argument]] end)
    end)
  end

  defp number(), do: value(:num)
  defp identifier(), do: value(:id)

  defp debug(parser, label) do
    map(parser, &IO.inspect(&1, label: label))
  end
end
