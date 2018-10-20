defmodule Tron.Player do
  # restart: transient allows the agent to be stopped and never restarted
  use Agent, restart: :transient
  @player_start_width 32
  @player_start_height 27
  @player_start_speed 160
  @min_speed 50

  def start_link(%{x: x, y: y, nick: nick}) do
    start = %{
      x: x,
      y: y,
      nick: nick,
      score: 0,
      size: %{w: @player_start_width, h: @player_start_height},
      speed: @player_start_speed,
    }
    Agent.start_link(fn -> start end)
  end

  def update_pos(pid, %{x: x, y: y}) do
    Agent.update pid, fn pos -> %{ pos | x: x, y: y } end
    view(pid)
  end

  def add_score(pid, increment) do
    Agent.update pid, fn player ->
      score = player.score + increment
      %{ player |
         score: score,
         size: score_to_size(score),
         speed: score_to_speed(score),
      }
    end
    view(pid)
  end

  def score_to_size(score) do
    %{
      w: @player_start_width + 2 * score,
      h: @player_start_height + 2 * score,
    }
  end

  def score_to_speed(score) do
    max @min_speed, @player_start_speed - score
  end

  def view(pid) do
    Agent.get pid, &(&1)
  end

  def stop(pid) do
    Agent.stop(pid, :normal)
  end
end
