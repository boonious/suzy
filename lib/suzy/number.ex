defmodule Suzy.Number do
  @moduledoc """
  Behaviour and struct of a number.

  This behaviour and default implementation forms a basis for
  other number implementations that deduce various attributes
  belonging to a number e.g. "modulo-n", "prime" etc.
  """

  @derive Jason.Encoder
  defstruct value: 1, attrs: [], stack: []

  @type t :: %__MODULE__{
          value: integer(),
          attrs: list(number() | atom()),
          stack: list(module())
        }

  @type num :: __MODULE__.t()

  @callback deduce(num()) :: num()

  defmacro __using__(_opts) do
    quote location: :keep do
      @behaviour unquote(__MODULE__)
      import unquote(__MODULE__)

      @impl true
      def deduce(number), do: number
      defoverridable deduce: 1
    end
  end

  @spec new(integer()) :: num()
  def new(integer \\ 1), do: %__MODULE__{value: integer}

  @spec new(num(), module()) :: num()
  def new(number, impl), do: %{number | stack: [impl | number.stack]}
end
