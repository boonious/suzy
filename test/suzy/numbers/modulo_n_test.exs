defmodule Suzy.Numbers.ModuloNTest do
  use ExUnit.Case, async: true

  alias Suzy.Number
  alias Suzy.Numbers

  defmodule TestMod2 do
    use Suzy.Numbers.ModuloN, n: 2
  end

  test "modulo_n" do
    assert %Number{attrs: [:mod_2]} = Numbers.new(4) |> TestMod2.deduce()
    assert %Number{attrs: []} = Numbers.new(5) |> TestMod2.deduce()
  end
end
