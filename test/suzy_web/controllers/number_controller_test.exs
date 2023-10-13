defmodule SuzyWeb.NumberControllerTest do
  use SuzyWeb.ConnCase, async: true
  alias Suzy.Numbers
  import SuzyWeb.NumberController, only: [default_page: 0, default_page_size: 0]

  setup do
    %{
      page: default_page() |> String.to_integer(),
      page_size: default_page_size() |> String.to_integer()
    }
  end

  describe "index/2" do
    test "without params", %{conn: conn, page: page, page_size: page_size} do
      conn = get(conn, ~p"/api/numbers")
      assert %{"numbers" => numbers} = json_response(conn, 200)
      assert length(numbers) == page_size
      assert hd(numbers) == %{"value" => 1, "attrs" => []}

      conn = get(conn, ~p"/numbers")
      assert html = html_response(conn, 200)
      assert {:ok, html} = Floki.parse_document(html)
      assert Floki.find(html, "#numbers-grid div") |> length() == page_size
      assert Floki.find(html, "#navigation a[href*=\"page=#{page + 1}\"]") != []
    end

    test "with paging params", %{conn: conn, page: page, page_size: page_size} do
      start = (page - 1) * page_size + 1
      conn = get(conn, ~p"/api/numbers?page=#{page}&page_size=#{page_size}")
      assert %{"numbers" => numbers} = json_response(conn, 200)
      assert length(numbers) == page_size
      assert %{"value" => ^start} = hd(numbers)

      start_s = "#{start}"
      conn = get(conn, ~p"/numbers?page=#{page}&page_size=#{page_size}")
      assert html = html_response(conn, 200)
      assert {:ok, html} = Floki.parse_document(html)
      assert Floki.find(html, "#numbers-grid div") |> length() == page_size
      assert [{_e, _attrs, [^start_s]}] = Floki.find(html, "#numbers-grid div:first-of-type")
    end

    test "when page param out of range", %{conn: conn} do
      {page, page_size} = {-1, 100}
      conn = get(conn, ~p"/api/numbers?page=#{page}&page_size=#{page_size}")
      assert %{"errors" => %{"detail" => _}} = json_response(conn, 400)

      conn = get(conn, ~p"/numbers?page=#{page}&page_size=#{page_size}")
      assert html_response(conn, 400) =~ "Bad Request"
    end

    test "when page size param out of range", %{conn: conn} do
      {page, page_size} = {1, Numbers.max_number() + 1}
      conn = get(conn, ~p"/api/numbers?page=#{page}&page_size=#{page_size}")
      assert %{"errors" => %{"detail" => _}} = json_response(conn, 400)

      conn = get(conn, ~p"/numbers?page=#{page}&page_size=#{page_size}")
      assert html_response(conn, 400) =~ "Bad Request"
    end
  end
end
