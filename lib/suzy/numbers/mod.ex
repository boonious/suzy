# generating the modulo-n deduction logic / middleware modules
for n <- Application.compile_env!(:suzy, :modulo_range) do
  defmodule Module.concat([Suzy.Numbers, "Mod#{n}"]) do
    use Suzy.Numbers.ModuloN, n: n
  end
end
