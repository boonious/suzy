defmodule SuzyWeb.NumberControllerTest do
  use SuzyWeb.ConnCase

  describe "/api" do
    test "GET /numbers", %{conn: conn} do
      conn = get(conn, ~p"/api/numbers")
      assert json_response(conn, 200) == %{}
    end
  end
end
