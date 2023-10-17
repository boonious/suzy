defmodule Suzy.Numbers.CacheGetTest do
  use ExUnit.Case, async: true
  import Hammox

  alias Suzy.CacheMock
  alias Suzy.Number
  alias Suzy.Numbers
  alias Suzy.Numbers.CacheGet

  setup do
    %{
      cache_value: {[:mod_3], [Numbers.Mod3]},
      number: %Number{
        value: 3,
        attrs: [:mod_3],
        stack: [Numbers.Mod3]
      }
    }
  end

  describe "deduce/1" do
    test "when number is cached", %{number: num, cache_value: cache_value} do
      CacheMock |> expect(:get, fn ^num -> cache_value end)
      assert %{status: {:ok, :from_cache}, cached: true} = num |> CacheGet.deduce()
    end

    test "when number is not cached", %{number: num} do
      CacheMock |> expect(:get, fn ^num -> nil end)
      assert %{status: nil, cached: false} = num |> CacheGet.deduce()
    end
  end
end
