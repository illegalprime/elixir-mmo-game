defmodule TronWeb.WorldChannel do
  use TronWeb, :channel
  alias Tron.Player.Registry
  alias Tron.Player

  def join("world:lobby", payload, socket) do
    if authorized?(payload) do
      # gather all current players and update everyone!
      players = Tron.Player.Registry.list_players
      # add the new player as a new process
      new_player = %{
        x: payload["x"],
        y: payload["y"],
        nick: payload["nick"],
      }
      {:ok, pid} = Registry.player_join payload["nick"], new_player, self()
      # lets keep this one around so we don't have to look it up
      socket = assign(socket, :player_pid, pid)
      socket = assign(socket, :nick, payload["nick"])
      # update all the other players after this one joins
      send(self(), {:new_player, new_player})
      # say we successfully joined and send already connected players
      {:ok, %{
          players: players,
          food: Tron.World.Food.list_foods,
       }, socket}
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
    # update all the player's states
    pid = socket.assigns[:player_pid]
    player = Player.update_pos(pid, %{x: x, y: y})
    # check if we ate any food
    food = Tron.World.Food.touches_food(player)
    # eat the food & increment score
    Tron.World.Food.eat_food(food)
    player = Player.add_score(pid, Enum.count(food))
    # send updates to everyone
    broadcast_from socket, "world", %{
      players: [player],
      eaten_food: food,
    }
    push socket, "world", %{
      eaten_food: food,
      player: player,
    }
    {:noreply, socket}
  end

  def handle_info({:new_player, new_player}, socket) do
    broadcast_from socket, "world", %{ players: [new_player] }
    {:noreply, socket}
  end

  def handle_info({:lost_player, nick}, socket) do
    push socket, "lost_player", %{ nick: nick }
    {:noreply, socket}
  end

  # Add authorization logic here as required.
  defp authorized?(_payload) do
    true
  end
end
