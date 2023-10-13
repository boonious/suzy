defmodule Suzy.Numbers.ModuloN do
  @moduledoc false

  defmacro __using__(mod: mod) do
    quote location: :keep, bind_quoted: [mod: mod] do
      use Suzy.Number
      @modulo mod

      # generate modulo-n deduce function implementation
      @impl true
      def deduce(%Suzy.Number{value: v, attrs: attrs} = num) do
        case rem(v, @modulo) do
          0 -> %{num | attrs: [:"mod#{@modulo}" | attrs]}
          _ -> num
        end
      end
    end
  end
end
