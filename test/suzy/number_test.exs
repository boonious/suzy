defmodule Suzy.NumberTest do
  use ExUnit.Case, async: true
  alias Suzy.Number

  defmodule NumberImpl do
    use Suzy.Number
  end

  test "new/0" do
    assert %Number{value: 1, attrs: []} == Number.new()
  end

  test "new/1" do
    assert %Number{value: 23, attrs: []} == Number.new(23)
  end

  test "new/2" do
    assert %Number{value: 5, attrs: [], stack: [NumberImplB, NumberImplA]} ==
             Number.new(5) |> Number.new(NumberImplA) |> Number.new(NumberImplB)
  end

  test "deduce/1" do
    assert %Number{value: 23, attrs: []} == Number.new(23) |> NumberImpl.deduce()
  end
end
