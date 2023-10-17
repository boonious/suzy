defmodule Suzy.Numbers.ModuloN do
  @moduledoc false

  defmacro __using__(n: n) do
    quote location: :keep, bind_quoted: [n: n] do
      use Suzy.Number
      alias Suzy.Number
      require Logger

      @n n

      # bypass deduction if number is fetched from cache
      @impl true
      def deduce(%Number{status: {:ok, :from_cache}} = num) do
        Logger.debug("Serving from cache, bypassing modulo-n deduction")
        num
      end

      # perform modulo-n deduction, `c:Number.deduce/1` implementation
      # writing the results to the `attrs` field.
      def deduce(%Number{status: nil} = num) do
        case rem(num.value, @n) do
          0 -> %{num | attrs: [:"mod_#{@n}" | num.attrs]}
          _ -> num
        end
      end
    end
  end
end
