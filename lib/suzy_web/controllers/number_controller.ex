defmodule SuzyWeb.NumberController do
  use SuzyWeb, :controller

  alias Suzy.Number
  alias Suzy.Numbers

  action_fallback SuzyWeb.FallbackController

  @chunk_size 100
  @page "1"
  @page_size "100"

  @doc """
  Stream or render numbers in JSON api and HTML view
  """
  def index(%{request_path: "/api/" <> _} = conn, params) do
    with {:ok, stream} <- num_range(params) |> Numbers.number_stream() do
      stream
      |> Stream.chunk_every(@chunk_size)
      |> Enum.reduce_while(
        put_resp_content_type(conn, "application/json") |> send_chunked(200),
        fn nums, conn -> send_chunks(conn, nums) end
      )
    end
  end

  def index(conn, params) do
    with {:ok, stream} <- num_range(params) |> Numbers.number_stream() do
      stream
      |> Stream.map(fn %Number{value: v} -> v end)
      |> Enum.to_list()
      |> then(fn nums -> render(conn, :index, nums: nums, pagination: pagination(params)) end)
    end
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

  defp validate(value, default) when value == "" or value == nil, do: default
  defp validate(value, _default), do: value

  defp send_chunks(conn, nums) do
    case chunk(conn, %{numbers: nums} |> Jason.encode!()) do
      {:ok, conn} -> {:cont, conn}
      {:error, :closed} -> {:halt, conn}
    end
  end

  @doc false
  def default_page, do: @page

  @doc false
  def default_page_size, do: @page_size
end
