defmodule Suzy.Cache.Server do
  @moduledoc false
  use GenServer
  require Logger

  alias Suzy.Number
  alias Suzy.Numbers.CachePut

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, name: Keyword.get(opts, :name, __MODULE__))
  end

  @impl true
  def init(opts), do: {:ok, Keyword.get(opts, :state, %{})}

  @impl true
  def handle_call({:put, %Number{} = number}, _from, state) do
    Logger.debug("Caching #{inspect(number)}")

    cache_value = {number.attrs, number.stack |> List.delete(CachePut)}
    {:reply, :ok, Map.put(state, number.value, cache_value)}
  end

  @impl true
  def handle_call({:get, num}, _from, state) when is_integer(num) do
    cache_value = state[num]
    if cache_value, do: Logger.debug("Cache hit for #{num}: #{inspect(cache_value)}")

    {:reply, cache_value, state}
  end
end
