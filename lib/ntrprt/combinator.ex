defmodule Ntrprt.Combinator do
  def choice(functions) do
    fn tokens ->
      case functions do
        [] ->
          {:error, ""}

        [function | other_functions] ->
          with {:error, _} <- function.(tokens) do
            choice(other_functions).(tokens)
          end
      end
    end
  end

  def sequence(functions) do
    fn tokens ->
      case functions do
        [] ->
          {:ok, [], tokens}

        [function | other_functions] ->
          with {:ok, left_value, tokens} <- function.(tokens),
               {:ok, right_value, tokens} <- sequence(other_functions).(tokens) do
            {:ok, [left_value | right_value], tokens}
          end
      end
    end
  end

  def zero_or_many(function) do
    fn tokens ->
      case function.(tokens) do
        {:error, _message} ->
          {:ok, [], tokens}

        {:ok, left_value, tokens} ->
          {:ok, right_value, tokens} = zero_or_many(function).(tokens)
          {:ok, [left_value | right_value], tokens}
      end
    end
  end

  def zero_or_one(function) do
    fn tokens ->
      case function.(tokens) do
        {:error, _message} ->
          {:ok, [], tokens}

        {:ok, value, tokens} ->
          {:ok, value, tokens}
      end
    end
  end

  def one_or_many(function) do
    fn tokens ->
      case function.(tokens) do
        {:error, message} ->
          {:error, message}

        {:ok, left_value, tokens} ->
          {:ok, right_value, tokens} = zero_or_many(function).(tokens)
          {:ok, [left_value | right_value], tokens}
      end
    end
  end

  def map(function, map_function) do
    fn tokens ->
      case function.(tokens) do
        {:ok, value, rest} ->
          {:ok, map_function.(value), rest}

        {:error, error} ->
          {:error, error}
      end
    end
  end

  def wrap(function) do
    map(function, fn value -> [value] end)
  end
end
