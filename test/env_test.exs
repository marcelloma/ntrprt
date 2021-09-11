defmodule EnvTest do
  use ExUnit.Case
  alias Ntrprt.Env

  def env() do
    Env.new()
  end

  test "initial state" do
    env = env()
    assert %Env{frames: [%{}]} = env
  end

  test "push_frame" do
    env = env()
    assert %Env{frames: [%{}, %{}]} = Env.push_frame(env)
  end

  test "pop_frame" do
    env = %Env{frames: [%{}, %{}]}
    assert %Env{frames: [%{}]} = Env.pop_frame(env)
  end

  test "set_variable" do
    %Env{frames: [%{}, %{}]}
    |> Env.set_variable(:a, "a")
    |> (&assert(%Env{frames: [%{a: "a"}, %{}]} = &1)).()
    |> Env.set_variable(:b, "b")
    |> (&assert(%Env{frames: [%{a: "a", b: "b"}, %{}]} = &1)).()
  end

  test "get_variable" do
    env = %Env{frames: [%{a: "a", b: "b1"}, %{b: "b2", c: "c"}]}

    assert "a" = Env.get_variable(env, :a)
    assert "b1" = Env.get_variable(env, :b)
    assert "c" = Env.get_variable(env, :c)
    refute Env.get_variable(env, :d)
  end
end
