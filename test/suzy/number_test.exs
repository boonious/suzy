defmodule Suzy.NumberTest do
  use ExUnit.Case, async: true
  alias Suzy.Number

  defmodule TestNumber do
    use Suzy.Number
  end

  test "new/0" do
    assert %Number{value: 1, attrs: []} == Number.new()
  end

  test "new/1" do
    assert %Number{value: 23, attrs: []} == Number.new(23)
  end

  test "deduce/1" do
    assert %Number{value: 23, attrs: []} == Number.new(23) |> __MODULE__.TestNumber.deduce()
  end
end
