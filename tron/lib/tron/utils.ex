defmodule Tron.Utils do
  @player_width 32
  @player_height 28

  # We use this to control the format of our usernames
  def verify_username(name) do
    Regex.match?(~r/^[a-z0-9_-]+$/i, name)
  end

  def mk_rect(%{x: x, y: y, nick: nick}) do
    %{
      nick: nick,
      x: x - @player_width / 2,
      y: y - @player_height / 2,
      width: @player_width,
      height: @player_height,
    }
  end
end
