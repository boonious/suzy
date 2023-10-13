# generate mod2 to mod10 modules for number modulo deduction
for modulo <- 2..10 do
  contents =
    quote do
      use Suzy.Numbers.ModuloN, mod: unquote(modulo)
    end

  Module.concat([Suzy, Numbers, "Mod#{modulo}"])
  |> Module.create(contents, Macro.Env.location(__ENV__))
end
