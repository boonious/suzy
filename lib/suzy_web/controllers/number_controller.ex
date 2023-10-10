defmodule SuzyWeb.NumberController do
  use SuzyWeb, :controller
  alias Suzy.Numbers

  action_fallback SuzyWeb.FallbackController

  @chunk_size 100
  @page "1"
  @page_size "100"

  def index(conn, params) do
    with {:ok, stream} <- num_range(params) |> Numbers.number_stream() do
      stream
      |> Stream.chunk_every(@chunk_size)
      |> Enum.reduce_while(
        put_resp_content_type(conn, "application/json") |> send_chunked(200),
        fn nums, conn -> send_chunks(conn, nums) end
      )
    end
  end

  defp num_range(params) do
    with {page_size, ""} <- (params["page_size"] || @page_size) |> Integer.parse(),
         {page, ""} <- (params["page"] || @page) |> Integer.parse() do
      start = (page - 1) * page_size
      {start + 1, start + page_size}
    end
  end

  defp send_chunks(conn, nums) do
    chunks = %{numbers: Enum.map(nums, fn num -> %{value: num} end)} |> Jason.encode!()

    case chunk(conn, chunks) do
      {:ok, conn} -> {:cont, conn}
      {:error, :closed} -> {:halt, conn}
    end
  end
end
