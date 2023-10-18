defmodule Suzy.Numbers.ModTest do
  use ExUnit.Case, async: true

  alias Suzy.Number
  alias Suzy.Numbers

  for modulo <- Application.compile_env!(:suzy, :modulo_range) do
    test "modulo #{modulo}" do
      modulo = unquote(modulo)
      mod_module = Module.concat(Numbers, "Mod#{modulo}")

      mod_atom = :"mod_#{modulo}"
      assert %Number{attrs: [^mod_atom]} = Numbers.new(modulo) |> mod_module.deduce()
      assert %Number{attrs: []} = Numbers.new(modulo + 1) |> mod_module.deduce()
    end
  end
end
