defmodule Ntrprt.Lexer do
  @symbols [?+, ?-, ?*, ?/, ?=, ?;, ?,, ?!, ?(, ?), ?{, ?}, ?;]
  @complex_symbols [[?-, ?>], [?=, ?=], [?!, ?=], [?<, ?=], [?>, ?=]]
  @new_line ?\n
  @whitespace [?\r, ?\v, ?\t, ?\s]
  @alpha ?A..?z
  @digits ?0..?9
  @string_delimiter ?"

  @keywords ["fn", "if", "else"]

  @type meta() :: %{line: integer(), column: integer()}
  @type token() :: {:atom, meta()} | {:atom, any(), meta()}

  @spec lex(String.t()) :: [token()]
  def lex(string) do
    lex(String.to_charlist(string), 0, 0)
  end

  defp lex([], _line, _column), do: []

  @spec lex(charlist(), integer(), integer()) :: [token()]
  defp lex(unprocessed, line, column) do
    {type, value, length} = read_token(unprocessed)

    token =
      if value do
        {type, value, %{line: line, column: column}}
      else
        {type, %{line: line, column: column}}
      end

    line = if type == :"\n", do: line + 1, else: line
    column = if type == :"\n", do: 0, else: column + length
    unprocessed = Enum.drop(unprocessed, length)

    if type == :" " do
      lex(unprocessed, line, column)
    else
      [token | lex(unprocessed, line, column)]
    end
  end

  @spec read_token(charlist()) :: {atom(), any(), integer()}
  defp read_token([char | _]) when char in @whitespace,
    do: {:" ", nil, 1}

  defp read_token([char | _]) when char == @new_line,
    do: {:"\n", nil, 1}

  defp read_token([char1, char2 | _]) when [char1, char2] in @complex_symbols do
    symbol =
      [<<char1::utf8>>, <<char2::utf8>>]
      |> List.to_string()
      |> String.to_atom()

    {symbol, nil, 2}
  end

  defp read_token([char | unprocessed]) when char == @string_delimiter do
    {value_chars, token_length} =
      unprocessed
      |> read_while(&(&1 != @string_delimiter))

    value = List.to_string(value_chars)
    token_length = token_length + 2

    {:str, value, token_length}
  end

  defp read_token([char | _]) when char in @symbols do
    {String.to_atom(<<char::utf8>>), nil, 1}
  end

  defp read_token([char | _] = unprocessed) when char in @digits do
    {value_chars, token_length} =
      unprocessed
      |> read_while(&(&1 in @digits || &1 in @alpha))

    {value, _} =
      value_chars
      |> List.to_string()
      |> Float.parse()

    {:num, value, token_length}
  end

  defp read_token([char | _] = unprocessed) when char in @alpha do
    {value_chars, token_length} =
      unprocessed
      |> read_while(&(&1 in @digits || &1 in @alpha))

    value = List.to_string(value_chars)

    if value in @keywords do
      {String.to_atom(value), nil, token_length}
    else
      {:id, value, token_length}
    end
  end

  @spec read_while(charlist(), (char() | [char()] -> boolean())) ::
          {charlist(), non_neg_integer()}
  defp read_while([], _fun), do: {[], 0}

  defp read_while([?\\, char | rest], fun) do
    if fun.([?\\, char]) do
      {matched, consumed} = read_while(rest, fun)
      {[char | matched], consumed + 2}
    else
      {[], 0}
    end
  end

  defp read_while([char | rest], fun) do
    if fun.(char) do
      {matched, consumed} = read_while(rest, fun)
      {[char | matched], consumed + 1}
    else
      {[], 0}
    end
  end
end
