defmodule Tron.Utils do
  # We use this to control the format of our usernames
  def verify_username(name) do
    Regex.match?(~r/^[a-z0-9_-]+$/i, name)
  end
end
