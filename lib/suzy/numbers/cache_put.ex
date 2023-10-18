defmodule Suzy.Numbers.CachePut do
  @moduledoc false
  use Suzy.Number
  alias Suzy.Number

  # do not cache number without attributes, e.g. modulo-n
  @impl true
  def deduce(%Number{attrs: []} = number) do
    number |> Map.put(:status, {:error, :invalid_number_for_cache})
  end

  def deduce(%Number{} = number) do
    :ok = cache().put(number)
    %{number | status: {:ok, :cached}, cached: true}
  end

  defp cache, do: Application.fetch_env!(:suzy, :cache)
end
