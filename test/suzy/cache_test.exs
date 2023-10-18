defmodule Suzy.CacheTest do
  use ExUnit.Case, async: true
  alias Suzy.Cache
  alias Suzy.Cache.Server
  alias Suzy.Number
  alias Suzy.Numbers

  @cache_server __MODULE__.Server

  setup do
    # initialise with a cache copy
    cache_value = {[:mod_3], [Numbers.Mod3]}
    initial_state = %{3 => cache_value}

    start_supervised(%{
      id: @cache_server,
      start: {Server, :start_link, [[name: @cache_server, state: initial_state]]}
    })

    %{
      cache_value: cache_value,
      number: %Number{
        value: 3,
        attrs: [:mod_3],
        stack: [Numbers.Mod3],
        __cache_server__: @cache_server
      }
    }
  end

  describe "get/1" do
    test "existing value from cache", %{number: num, cache_value: value} do
      assert Cache.get(num) == value
    end

    test "non existing cache", %{number: num} do
      assert Cache.get(%{num | value: 500}) == nil
    end
  end

  test "put/1", %{number: num, cache_value: value} do
    :sys.replace_state(@cache_server, fn _state -> %{} end)

    assert :sys.get_state(@cache_server) == %{}
    assert Cache.put(num) == :ok
    assert :sys.get_state(@cache_server) == %{3 => value}
  end
end
