defmodule Tron.World.Food do
  use GenServer
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

  #
  # Server-Side functions
  #
  def init(:ok) do
    # we maintain a Quad-Tree of food
    state = %{
      qtree: QuadTree.create(width: @world_width, height: @world_height),
      foods: %{},
    }
    # populate state with a bunch of random foods
    foods = populate(state.qtree.rectangle, @food_number)
    qtree = foods
    |> Enum.reduce(state.qtree, fn {_, f}, t -> QuadTree.insert(t, f) end)
    {:ok, %{ foods: Enum.into(foods, %{}), qtree: qtree }}
  end

  def handle_call({:list}, _from, state) do
    {:reply, state.foods, state}
  end

  defp populate(bbox, number) do
    Enum.map(1..number, fn idx -> {idx, rand_bbox(bbox)} end)
  end

  defp rand_bbox(bbox) do
    %Rectangle{
      x: Enum.random(bbox.x..(bbox.x + bbox.width)),
      y: Enum.random(bbox.y..(bbox.y + bbox.height)),
      width: @food_width,
      height: @food_height,
    }
  end
end
