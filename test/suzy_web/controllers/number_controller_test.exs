defmodule SuzyWeb.NumberControllerTest do
  use SuzyWeb.ConnCase, async: true

  import SuzyWeb.NumberController, only: [default_page: 0, default_page_size: 0]
  import Hammox

  alias Suzy.CacheMock
  alias Suzy.Number
  alias Suzy.Numbers

  setup :verify_on_exit!

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
      assert hd(numbers) == %{"value" => 1, "attrs" => [], "cached" => false}

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
      assert %{"attrs" => ["mod_3"], "cached" => false, "value" => 3} in numbers
      assert %{"attrs" => ["mod_5"], "cached" => false, "value" => 5} in numbers
      assert %{"attrs" => ["mod_5", "mod_3"], "cached" => false, "value" => 15} in numbers
      assert %{"attrs" => [], "cached" => false, "value" => 1} in numbers

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

    test "calls cache when cache_get in attrs params", %{conn: conn} do
      pg_size = 5
      CacheMock |> expect(:get, pg_size, fn %Number{} -> nil end)

      conn =
        get(conn, ~p"/api/numbers?page=1&page_size=#{pg_size}&attrs[]=mod_3&attrs[]=cache_get")

      assert %{"numbers" => _} = json_response(conn, 200)

      CacheMock |> expect(:get, pg_size, fn %Number{} -> nil end)
      conn = get(conn, ~p"/numbers?page=1&page_size=#{pg_size}&attrs[]=mod_3&attrs[]=cache_get")
      assert html = html_response(conn, 200)
      assert {:ok, html} = Floki.parse_document(html)

      # cache number link availability
      assert [{"a", attrs, [span]}] = Floki.find(html, "#numbers-grid #num-3 a")
      assert {"data-method", "post"} in attrs
      assert {"href", "/numbers/3?attrs%5B%5D=mod_3"} in attrs

      # cached number icon not set
      assert {"span", [{"class", class}], []} = span
      assert class =~ "hero-star"
    end

    test "uses cache if it exists", %{conn: conn} do
      pg_size = 3

      CacheMock
      |> stub(:get, fn num -> if num.value == 3, do: {[:mod_3], []}, else: nil end)

      conn =
        get(conn, ~p"/api/numbers?page=1&page_size=#{pg_size}&attrs[]=mod_3&attrs[]=cache_get")

      assert %{"numbers" => numbers} = json_response(conn, 200)
      assert %{"attrs" => ["mod_3"], "cached" => true, "value" => 3} in numbers

      conn = get(conn, ~p"/numbers?page=1&page_size=#{pg_size}&attrs[]=mod_3&attrs[]=cache_get")
      assert html = html_response(conn, 200)
      assert {:ok, html} = Floki.parse_document(html)
      assert [{"div", _, content}] = Floki.find(html, "#numbers-grid #num-3")

      # cached number icon set
      assert [{"span", [{"class", class}], []}] = Floki.find(content, "span.cache_icon")
      assert class =~ "hero-star-solid"
    end
  end

  describe "index/2 errors" do
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

  describe "post/2" do
    test "caches mod-n number", %{conn: conn} do
      CacheMock
      |> expect(:put, 2, fn %Number{value: 3, attrs: [:mod_3]} -> :ok end)

      conn = post(conn, ~p"/api/numbers/3?attrs[]=mod_3")
      assert %{"number" => 3} = json_response(conn, 200)

      conn = post(conn, ~p"/numbers/3?attrs[]=mod_3")
      assert html = html_response(conn, 200)
      assert html =~ "Cached"
    end

    test "when number not mod-n", %{conn: conn} do
      CacheMock |> expect(:put, 0, fn _ -> :ok end)
      conn = post(conn, ~p"/api/numbers/4?attrs[]=mod_3")
      assert %{"errors" => %{"detail" => _}} = json_response(conn, 400)

      conn = post(conn, ~p"/numbers/4?attrs[]=mod_3")
      assert html_response(conn, 400)
    end

    test "when number param not a number", %{conn: conn} do
      CacheMock |> expect(:put, 0, fn _ -> :ok end)
      conn = post(conn, ~p"/api/numbers/a_string?attrs[]=mod_3")
      assert %{"errors" => %{"detail" => _}} = json_response(conn, 400)

      conn = post(conn, ~p"/numbers/a_string?attrs[]=mod_3")
      assert html_response(conn, 400)
    end
  end
end
