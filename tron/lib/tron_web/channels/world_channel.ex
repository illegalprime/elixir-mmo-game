defmodule TronWeb.WorldChannel do
  use TronWeb, :channel
  alias Tron.Player.Registry
  alias Tron.Player

  def join("world:lobby", payload, socket) do
    if authorized?(payload) do
      # add the new player as a new process
      {:ok, pid} = Registry.player_join payload["nick"], %{
        x: payload["x"],
        y: payload["y"],
        nick: payload["nick"],
      }
      # lets keep this one around so we don't have to look it up
      socket = assign(socket, :player_pid, pid)
      # say we successfully joined
      {:ok, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (world:lobby).
  def handle_in("shout", payload, socket) do
    broadcast_from socket, "shout", payload
    {:noreply, socket}
  end

  # Update the position of each player
  def handle_in("position", %{"x" => x, "y" => y}, socket) do
    # TODO: check if update is too large here to prevent cheating
    Player.update_pos(socket.assigns[:player_pid], %{x: x, y: y})
    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
