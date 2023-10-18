defmodule Suzy.Cache do
  @moduledoc false
  require Logger
  alias Suzy.Number

  @type num :: Number.t()
  @type stack :: Number.stack()

  @type cache_value :: nil | {Number.attrs(), Number.stack()}
  @type cache_server :: GenServer.server()

  @callback get(num()) :: cache_value() | {:error, term()}
  @callback put(num()) :: :ok | {:error, term()}

  def get(%Number{} = num), do: GenServer.call(num.__cache_server__, {:get, num.value})
  def put(%Number{} = num), do: GenServer.call(num.__cache_server__, {:put, num})
end
