defmodule SuzyWeb.NumberController do
  use SuzyWeb, :controller
  alias Suzy.Numbers

  action_fallback SuzyWeb.FallbackController

  @attrs []
  @attr_regex ~r/mod_([2-9]|10)$|cache_get/
  @chunk_size 100
  @page "1"
  @page_size "100"

  @doc """
  Stream numbers via JSON api or render numbers HTML view
  """
  def index(%{request_path: "/api/" <> _} = conn, params) do
    with {:ok, attrs} <- validate(params["attrs"]),
         {:ok, stream} <- number_stream(params, attrs) do
      stream
      |> Stream.chunk_every(@chunk_size)
      |> Enum.reduce_while(
        put_resp_content_type(conn, "application/json") |> send_chunked(200),
        fn nums, conn -> send_chunks(conn, nums) end
      )
    end
  end

  def index(conn, params) do
    with {:ok, attrs} <- validate(params["attrs"]),
         {:ok, stream} <- number_stream(params, attrs) do
      stream
      |> Stream.map(fn num -> Map.from_struct(num) end)
      # memory-bound bottleneck for now
      |> Enum.to_list()
      |> then(fn nums ->
        render(conn, :index,
          nums: nums,
          pagination: pagination(params),
          attrs: attrs
        )
      end)
    end
  end

  defp number_stream(params, attrs) do
    num_range(params) |> Numbers.number_stream(attrs |> stack())
  end

  def cache(conn, %{"number" => number} = params) do
    with {:ok, attrs} <- validate(params["attrs"]),
         {:ok, number} <- parse_integer(number),
         {:ok, :cached} <- cache_number(number, attrs) do
      conn |> put_status(200)

      case conn.request_path do
        "/api/" <> _ -> conn |> json(%{number: number})
        _ -> render(conn, :cache, num: %{value: number, attrs: attrs, cached: true})
      end
    end
  end

  defp parse_integer(number) do
    case Integer.parse(number) do
      {integer, _} -> {:ok, integer}
      :error -> {:error, :not_integer}
    end
  end

  defp cache_number(number, attrs) do
    num = Numbers.new(number, (attrs |> stack()) ++ [Numbers.CachePut]) |> Numbers.deduce()
    num.status
  end

  defp num_range(params) do
    with {page_size, ""} <- validate(params["page_size"], default_page_size()) |> Integer.parse(),
         {page, ""} <- validate(params["page"], default_page()) |> Integer.parse() do
      start = (page - 1) * page_size
      {start + 1, start + page_size}
    end
  end

  defp pagination(params) do
    with {page_size, ""} <- validate(params["page_size"], default_page_size()) |> Integer.parse(),
         {page, ""} <- validate(params["page"], default_page()) |> Integer.parse() do
      %{"page" => page, "page_size" => page_size}
    end
  end

  defp stack([]), do: []

  # maps attribute (e.g. `mod_3`) to its corresponding deduction module (`Suzy.Numbers.Mod3`)
  # because the mapping generates atoms, `validate/1` currently ensures only `mod_2` to `mod_10`
  # values are accepted.
  defp stack(attrs) do
    for attr <- attrs, attr != "" and valid_attr?(attr) do
      Module.concat([Numbers, attr |> Macro.camelize()])
    end
  end

  defp validate(attrs) do
    attrs = attrs || default_attrs()

    for attr <- attrs, attr != "" do
      String.match?(attr, @attr_regex)
    end
    |> Enum.any?(&(&1 == false))
    |> case do
      true -> {:error, :bad_attr}
      false -> {:ok, attrs}
    end
  end

  defp validate(value, default) when value == "" or value == nil, do: default
  defp validate(value, _default), do: value

  defp valid_attr?(attr), do: String.match?(attr, @attr_regex)

  defp send_chunks(conn, nums) do
    case chunk(conn, %{numbers: nums} |> Jason.encode!()) do
      {:ok, conn} -> {:cont, conn}
      {:error, :closed} -> {:halt, conn}
    end
  end

  @doc false
  def default_attrs, do: @attrs

  @doc false
  def default_page, do: @page

  @doc false
  def default_page_size, do: @page_size
end
