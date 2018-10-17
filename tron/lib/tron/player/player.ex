defmodule Tron.Player do
  use Agent

  def start_link(%{x: x, y: y, nick: nick}) do
    Agent.start_link(fn -> %{x: x, y: y, nick: nick} end)
  end

  def update_pos(pid, %{x: x, y: y}) do
    Agent.update pid, fn pos -> %{ pos | x: x, y: y } end
  end

  def view(pid) do
    Agent.get pid, &(&1)
  end
end
