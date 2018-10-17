defmodule Tron.Player.Registry do
  use GenServer

  #
  # Client-Side functions
  #
  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def player_join(id, player) do
    GenServer.call(__MODULE__, {:create, id, player})
  end

  def player_pid(id) do
    GenServer.call(__MODULE__, {:lookup, id})
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
    {:reply, ids, ids}
  end

  def handle_call({:create, id, player}, _from, ids) do
    if Map.has_key?(ids, id) do
      {:reply, {:err, "already joined"}, ids}
    else
      {:ok, pid} = DynamicSupervisor.start_child(Tron.PlayerSupervisor, {
            Tron.Player,
            player,
      })
      {:reply, {:ok, pid}, Map.put(ids, id, pid)}
    end
  end
end
