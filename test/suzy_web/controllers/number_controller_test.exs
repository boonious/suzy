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

      start = "#{start}"
      conn = get(conn, ~p"/numbers?page=#{page}&page_size=#{page_size}")
      assert html = html_response(conn, 200)
      assert {:ok, html} = Floki.parse_document(html)
      assert Floki.find(html, "#numbers-grid div") |> length() == page_size
      assert [{_e, _attrs, [num_html]}] = Floki.find(html, "#numbers-grid div:first-of-type")
      assert start =~ num_html |> String.trim()
    end

    test "with mod-n attrs params", %{conn: conn} do
      conn = get(conn, ~p"/api/numbers?page=1&page_size=20&attrs[]=mod_3&attrs[]=mod_5")
      assert %{"numbers" => numbers} = json_response(conn, 200)
      assert %{"attrs" => ["mod_3"], "value" => 3} in numbers
      assert %{"attrs" => ["mod_5"], "value" => 5} in numbers
      assert %{"attrs" => ["mod_3", "mod_5"], "value" => 15} in numbers
      assert %{"attrs" => [], "value" => 1} in numbers

      conn = get(conn, ~p"/numbers?page=1&page_size=5&attrs[]=mod_3&attrs[]=mod_5")
      assert html = html_response(conn, 200)
      assert {:ok, html} = Floki.parse_document(html)

      assert [{"div", _, content}] = Floki.find(html, "#numbers-grid #num-3")
      assert "3" in (content |> Enum.filter(&is_binary/1) |> Enum.map(&String.trim/1))
      assert [{"span", _, ["mod_3"]}] = Floki.find(content, "span.badge")

      assert [{"div", _, content}] = Floki.find(html, "#numbers-grid #num-5")
      assert "5" in (content |> Enum.filter(&is_binary/1) |> Enum.map(&String.trim/1))
      assert [{"span", _, ["mod_5"]}] = Floki.find(content, "span.badge")
    end

    test "when mod-n param is invalid", %{conn: conn} do
      conn = get(conn, ~p"/api/numbers?page=1&page_size=20&attrs[]=invalid")
      assert %{"errors" => _} = json_response(conn, 400)

      conn = get(conn, ~p"/numbers?page=1&page_size=20&attrs[]=invalid")
      assert html_response(conn, 400)
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
