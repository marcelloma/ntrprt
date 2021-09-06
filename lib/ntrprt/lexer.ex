defmodule Ntrprt.Lexer do
  defstruct [:code, :token, tokens: []]

  def lex(code) when is_binary(code) do
    lex(%__MODULE__{code: code})
  end

  def lex(%{code: <<>>, tokens: tokens, token: nil}),
    do: tokens |> Enum.reverse() |> Enum.filter(&(elem(&1, 0) != :skip_token))

  def lex(state) do
    [&number_rule/1, &operator_rule/1, &space_rule/1, &identifier_rule/1, &fail_rule/1]
    |> Enum.reduce(state, &apply_rule(&2, &1))
    |> push_token()
    |> lex()
  end

  def apply_rule(state, _rule) when not is_nil(state.token), do: state
  def apply_rule(state, rule), do: rule.(state)

  def number_rule(state, acc \\ nil) do
    {char, new_state} = next_char(state)

    parse_result = Integer.parse(if char, do: <<char::utf8>>, else: <<>>)

    cond do
      parse_result == :error && is_nil(acc) ->
        state

      parse_result == :error ->
        %{state | token: {:token, :number, acc}}

      true ->
        {number, _} = parse_result
        number_rule(new_state, (acc || 0) * 10 + number)
    end
  end

  def identifier_rule(state, prev_chars \\ <<>>) do
    {char, new_state} = next_char(state)

    char = if char, do: char, else: <<>>

    is_letter = is_letter?(char)
    is_number = is_number?(char)

    cond do
      is_letter && char == <<>> ->
        identifier_rule(new_state, prev_chars <> <<char>>)

      is_letter || is_number ->
        identifier_rule(new_state, prev_chars <> <<char>>)

      !is_letter && !is_number && prev_chars != <<>> ->
        %{state | token: check_for_keyword(prev_chars)}

      !is_letter && char == <<>> ->
        state

      true ->
        state
    end
  end

  def check_for_keyword(identifier) do
    if identifier == "fn" do
      {:token, :fn}
    else
      {:token, :identifier, identifier}
    end
  end

  def operator_rule(state, prev_chars \\ <<>>) do
    {char, new_state} = next_char(state)

    chars = prev_chars <> <<char::utf8>>

    cond do
      chars == "->" -> %{new_state | token: {:token, :->}}
      chars == "+" -> %{new_state | token: {:token, :+}}
      chars == "-" -> operator_rule(new_state, chars) || %{new_state | token: {:token, :-}}
      chars == "/" -> %{new_state | token: {:token, :/}}
      chars == "*" -> %{new_state | token: {:token, :*}}
      chars == "=" -> %{new_state | token: {:token, :=}}
      chars == "(" -> %{new_state | token: {:token, :lparen}}
      chars == ")" -> %{new_state | token: {:token, :rparen}}
      chars == "{" -> %{new_state | token: {:token, :lbrace}}
      chars == "}" -> %{new_state | token: {:token, :rbrace}}
      chars == "\n" -> %{new_state | token: {:token, :newline}}
      chars == ";" -> %{new_state | token: {:token, :semi}}
      chars == "," -> %{new_state | token: {:token, :comma}}
      prev_chars != <<>> -> nil
      true -> state
    end
  end

  def space_rule(state) do
    {char, new_state} = next_char(state)

    if char == ?\s do
      %{new_state | token: {:skip_token}}
    else
      state
    end
  end

  def fail_rule(state) do
    {char, _} = next_char(state)
    raise "could not lex #{<<char::utf8>>}"
  end

  def next_char(state) do
    case state.code do
      <<char::utf8, code::binary>> -> {char, %{state | code: code}}
      <<>> -> {nil, state}
    end
  end

  def push_token(state) do
    state
    |> Map.put(:token, nil)
    |> Map.update!(:tokens, &[state.token | &1])
  end

  defp is_letter?(char) when char in ?a..?z, do: true
  defp is_letter?(_char), do: false

  defp is_number?(char) when char in ?0..?9, do: true
  defp is_number?(_char), do: false
end
