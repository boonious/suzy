defmodule SuzyWeb.NumberHtmlTest do
  use SuzyWeb.ConnCase, async: true
  import Phoenix.LiveViewTest

  alias Suzy.Number
  alias Suzy.Numbers
  alias SuzyWeb.NumberHTML

  test "number/1" do
    num = %Number{value: 1002} |> Map.from_struct()
    assert render_component(&NumberHTML.number/1, num: num) =~ "1002"
  end

  test "number/1 with attrs (mod) badges" do
    num = %Number{value: 3, attrs: [:mod_3]} |> Map.from_struct()
    assert render_component(&NumberHTML.number/1, num: num) =~ "mod_3"

    num = %Number{value: 15, attrs: [:mod_3, :mod_5]} |> Map.from_struct()
    assert render_component(&NumberHTML.number/1, num: num) =~ "mod_3,_5"
  end

  test "numbers_grid/1" do
    nums = [6, 7, 8]

    html =
      render_component(&NumberHTML.numbers_grid/1,
        nums: nums |> Enum.map(&(Numbers.new(&1) |> Map.from_struct()))
      )

    assert {:ok, html} = Floki.parse_document(html)
    assert Floki.find(html, "#numbers-grid div") |> length() == 3
    for num <- nums, do: assert(Floki.find(html, "#numbers-grid div:fl-contains('#{num}')") != [])
  end

  describe "navigation/1" do
    test "render with pagination params" do
      {page, page_size} = {3, 13}
      pagination = %{"page" => page, "page_size" => page_size}
      html = render_component(&NumberHTML.navigation/1, pagination: pagination, attrs: [])

      assert {:ok, html} = Floki.parse_document(html)
      assert Floki.find(html, "form") != []

      # prev / next page links
      assert Floki.find(html, "a[href*=\"page=#{page - 1}\"]") != []
      assert Floki.find(html, "a[href*=\"page=#{page + 1}\"]") != []
      assert Floki.find(html, "a[href*=\"page_size=#{page_size}\"]") |> length() == 2

      # page / page size form inputs
      assert Floki.find(html, "input#page[value=\"#{page}\"}]") != []
      assert Floki.find(html, "input#page_size[value=\"#{page_size}\"}]") != []
    end

    test "when current page is 1" do
      {page, page_size} = {1, 10}
      pagination = %{"page" => page, "page_size" => page_size}
      html = render_component(&NumberHTML.navigation/1, pagination: pagination, attrs: [])

      assert {:ok, html} = Floki.parse_document(html)
      refute Floki.find(html, "a[href*=\"page=#{page - 1}\"]") != []
      assert Floki.find(html, "span:fl-contains('Prev')") |> length() == 1
    end
  end
end
