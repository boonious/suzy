defmodule Suzy.Numbers.CachePutTest do
  use ExUnit.Case, async: true
  import Hammox

  alias Suzy.CacheMock
  alias Suzy.Number
  alias Suzy.Numbers
  alias Suzy.Numbers.CachePut

  setup do
    %{
      number: %Number{
        value: 3,
        attrs: [:mod_3],
        stack: [Numbers.Mod3]
      }
    }
  end

  describe "deduce/1" do
    test "puts a number into cache", %{number: num} do
      CacheMock |> expect(:put, fn ^num -> :ok end)
      assert %{status: {:ok, :cached}, cached: true} = num |> CachePut.deduce()
    end

    test "when number is not value", %{number: num} do
      num = %{num | value: 4, attrs: []}
      CacheMock |> expect(:put, fn ^num -> {:error, :invalid_number_for_cache} end)

      assert %{status: {:error, :invalid_number_for_cache}, cached: false} =
               num |> CachePut.deduce()
    end
  end
end
