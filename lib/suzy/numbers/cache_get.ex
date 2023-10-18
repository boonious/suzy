defmodule Suzy.Numbers.CacheGet do
  @moduledoc false
  use Suzy.Number
  alias Suzy.Number

  @impl true
  def deduce(%Number{} = num) do
    case cache().get(num) do
      nil ->
        num

      {attrs, stack} ->
        %{num | attrs: attrs, stack: stack, status: {:ok, :from_cache}, cached: true}
    end
  end

  defp cache, do: Application.fetch_env!(:suzy, :cache)
end
