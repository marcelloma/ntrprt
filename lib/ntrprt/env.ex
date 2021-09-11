defmodule Ntrprt.Env do
  defstruct [:frames]

  def new() do
    %Ntrprt.Env{frames: [%{}]}
  end

  def push_frame(env) do
    Map.update!(env, :frames, &[%{} | &1])
  end

  def pop_frame(%Ntrprt.Env{frames: frames}) when length(frames) == 1,
    do: raise("cannot pop the last frame")

  def pop_frame(env) do
    Map.update!(env, :frames, &Enum.drop(&1, 1))
  end

  def get_variable(%Ntrprt.Env{} = env, key), do: get_variable(env.frames, key)

  def get_variable([], _key), do: nil

  def get_variable([frame | other_frames], key) do
    if Map.has_key?(frame, key) do
      Map.get(frame, key)
    else
      get_variable(other_frames, key)
    end
  end

  def set_variable(env, key, value) do
    Map.update!(env, :frames, fn [frame | other_frames] ->
      [Map.put(frame, key, value) | other_frames]
    end)
  end

  def set_variables(env, []), do: env

  def set_variables(env, [{key, value} | other_variables]) do
    env
    |> set_variable(key, value)
    |> set_variables(other_variables)
  end
end
