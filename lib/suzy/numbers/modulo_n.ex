defmodule Suzy.Numbers.ModuloN do
  @moduledoc false

  defmacro __using__(n: n) do
    quote location: :keep, bind_quoted: [n: n] do
      use Suzy.Number
      @n n

      # modulo-n deduction, `c:Number.deduce/1` implementation
      # writing the results to the `attrs` field.
      @impl true
      def deduce(%Suzy.Number{value: v, attrs: attrs} = num) do
        case rem(v, @n) do
          0 -> %{num | attrs: [:"mod_#{@n}" | attrs]}
          _ -> num
        end
      end
    end
  end
end
