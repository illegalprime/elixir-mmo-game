defmodule Tron.World.Food do
  use GenServer
  alias Tron.Utils

  @world_width 700
  @world_height 600
  @food_width 9
  @food_height 10
  @food_number 100

  #
  # Client-Side functions
  #
  def start_link(opts) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def list_foods do
    GenServer.call(__MODULE__, {:list})
  end

  def touches_food(player) do
    GenServer.call(__MODULE__, {:touches_food, player})
  end

  def eat_food(ids) do
    GenServer.cast(__MODULE__, {:eat, ids})
  end

  #
  # Server-Side functions
  #
  def init(:ok) do
    # we maintain a Quad-Tree of food
    state = %{
      qtree: QuadTree.create(width: @world_width, height: @world_height),
      foods: %{},
      eaten: [],
    }
    # populate state with a bunch of random foods
    foods = populate(state.qtree.rectangle, @food_number)
    qtree = foods
    |> Enum.reduce(state.qtree, fn {_, f}, t -> QuadTree.insert(t, f) end)
    {:ok, %{ state | foods: Enum.into(foods, %{}), qtree: qtree }}
  end

  def handle_call({:list}, _from, state) do
    {:reply, state.foods, state}
  end

  def handle_call({:touches_food, player}, _from, state) do
    touching = QuadTree.query(state.qtree, Utils.mk_rect(player))
    |> Enum.map(fn player -> player[:id] end)
    |> Enum.filter(fn id -> Map.get(state.foods, id) end)
    {:reply, touching, state}
  end

  def handle_cast({:eat, ids}, state) do
    foods = Map.drop(state.foods, ids)
    {:noreply, %{ state | foods: foods, eaten: state.eaten ++ ids }}
  end

  defp populate(bbox, number) do
    Enum.map(1..number, fn idx -> {idx, rand_bbox(bbox, idx)} end)
  end

  defp rand_bbox(bbox, id) do
    %{
      id: id,
      x: Enum.random(bbox.x..(bbox.x + bbox.width)),
      y: Enum.random(bbox.y..(bbox.y + bbox.height)),
      width: @food_width,
      height: @food_height,
    }
  end
end
