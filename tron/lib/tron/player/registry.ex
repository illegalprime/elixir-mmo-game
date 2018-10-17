defmodule Tron.Player.Registry do
  use GenServer

  #
  # Client-Side functions
  #
  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def player_join(id, player, channel) do
    GenServer.call(__MODULE__, {:create, id, player, channel})
  end

  def player_pid(id) do
    {:ok, player} = GenServer.call(__MODULE__, {:lookup, id})
    player[:pid]
  end

  def list_players do
    GenServer.call(__MODULE__, {:list})
  end

  #
  # Server-Side functions
  #
  def init(:ok) do
    # always begin with an empty map
    {:ok, %{}}
  end

  def handle_call({:lookup, id}, _from, ids) do
    {:reply, Map.fetch(ids, id), ids}
  end

  def handle_call({:list}, _from, ids) do
    players = ids
    |> Map.values
    |> Enum.map(fn player -> Tron.Player.view(player[:pid]) end)
    {:reply, players, ids}
  end

  def handle_call({:create, id, player, channel}, _from, ids) do
    if Map.has_key?(ids, id) do
      {:reply, {:err, "already joined"}, ids}
    else
      # Start the player agent to maintain its state
      {:ok, pid} = DynamicSupervisor.start_child(Tron.PlayerSupervisor, {
            Tron.Player,
            player,
      })
      # monitor the channel so we can cleanup this player on disconnect
      monitor_ref = Process.monitor(channel)
      # add pid and channel to our map
      entry = %{
        pid: pid,
        monitor: monitor_ref,
        channel: channel,
      }
      {:reply, {:ok, pid}, Map.put(ids, id, entry)}
    end
  end

  def handle_info({:DOWN, ref, :process, _channel, _reason}, ids) do
    # find the player that got disconnected
    {nick, player} = ids
    |> Map.to_list
    |> Enum.find(fn entry -> elem(entry, 1)[:monitor] == ref end)
    # stop it
    Tron.Player.stop(player[:pid])
    # remove it from our own map
    ids = Map.delete(ids, nick)
    # send updates to all the other processes
    ids
    |> Map.values
    |> Enum.map(fn player -> player[:channel] end)
    |> Enum.each(fn channel -> send(channel, {:lost_player, nick}) end)
    # save the update map
    {:noreply, ids}
  end
end
