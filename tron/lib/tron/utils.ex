defmodule Tron.Utils do
  # We use this to control the format of our usernames
  def verify_username(name) do
    Regex.match?(~r/^[a-z0-9_-]+$/i, name)
  end

  def mk_rect(%{x: x, y: y, nick: nick, size: size}) do
    %{
      nick: nick,
      x: x - size.w / 2,
      y: y - size.h / 2,
      width: size.w,
      height: size.h,
    }
  end
end
