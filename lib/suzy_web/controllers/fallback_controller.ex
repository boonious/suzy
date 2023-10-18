defmodule SuzyWeb.FallbackController do
  @moduledoc """
  Translates controller action results into valid `Plug.Conn` responses.

  See `Phoenix.Controller.action_fallback/1` for more details.
  """
  use SuzyWeb, :controller

  @err_400 [:num_out_of_range, :bad_attr]

  # This clause is an example of how to handle resources that cannot be found.
  def call(conn, {:error, :not_found}) do
    conn
    |> put_status(:not_found)
    |> put_view(html: SuzyWeb.ErrorHTML, json: SuzyWeb.ErrorJSON)
    |> render(:"404")
  end

  def call(conn, {:error, error}) when error in @err_400 do
    conn
    |> put_status(400)
    |> put_view(html: SuzyWeb.ErrorHTML, json: SuzyWeb.ErrorJSON)
    |> render(:"400")
  end
end
