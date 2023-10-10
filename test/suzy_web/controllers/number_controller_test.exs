defmodule SuzyWeb.NumberControllerTest do
  alias Suzy.Numbers
  use SuzyWeb.ConnCase

  describe "GET /api/numbers" do
    test "without params", %{conn: conn} do
      conn = get(conn, ~p"/api/numbers")

      assert %{"numbers" => numbers} = json_response(conn, 200)
      assert length(numbers) > 0
      assert hd(numbers) == %{"value" => 1}
    end

    test "with paging params", %{conn: conn} do
      {page, page_size} = {2, 10}
      start = (page - 1) * page_size + 1
      conn = get(conn, ~p"/api/numbers?page=#{page}&page_size=#{page_size}")

      assert %{"numbers" => numbers} = json_response(conn, 200)
      assert length(numbers) == page_size
      assert %{"value" => ^start} = hd(numbers)
    end

    test "when page param out of range", %{conn: conn} do
      {page, page_size} = {-1, 100}
      conn = get(conn, ~p"/api/numbers?page=#{page}&page_size=#{page_size}")
      assert %{"errors" => %{"detail" => _}} = json_response(conn, 400)
    end

    test "when page size param out of range", %{conn: conn} do
      {page, page_size} = {1, Numbers.max_number() + 1}
      conn = get(conn, ~p"/api/numbers?page=#{page}&page_size=#{page_size}")
      assert %{"errors" => %{"detail" => _}} = json_response(conn, 400)
    end
  end
end
