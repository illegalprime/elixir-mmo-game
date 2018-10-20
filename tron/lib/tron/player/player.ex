defmodule Tron.Player do
  # restart: transient allows the agent to be stopped and never restarted
  use Agent, restart: :transient

  def start_link(%{x: x, y: y, nick: nick}) do
    start = %{
      x: x,
      y: y,
      nick: nick,
      score: 0,
    }
    Agent.start_link(fn -> start end)
  end

  def update_pos(pid, %{x: x, y: y}) do
    Agent.update pid, fn pos -> %{ pos | x: x, y: y } end
    view(pid)
  end

  def add_score(pid, increment) do
    Agent.update pid, fn pos -> %{ pos | score: pos.score + increment } end
    view(pid).score
  end

  def view(pid) do
    Agent.get pid, &(&1)
  end

  def stop(pid) do
    Agent.stop(pid, :normal)
  end
end
