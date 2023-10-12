defmodule SuzyWeb.NumberHTML do
  use SuzyWeb, :html

  embed_templates "number_html/*"

  attr :num, :integer, required: true

  def number(assigns) do
    ~H"""
    <div class="p-4 rounded-lg shadow-lg bg-slate-100"><%= @num %></div>
    """
  end

  attr :nums, :list, required: true

  def numbers_grid(assigns) do
    ~H"""
    <section
      id="numbers-grid"
      class="grid grid-cols-10 gap-4 font-mono text-sm text-center font-bold rounded-lg"
    >
      <.number :for={num <- @nums} num={num} />
    </section>
    """
  end

  attr :pagination, :map, required: true

  def navigation(assigns) do
    ~H"""
    <% {pg, pg_size} = {@pagination["page"], @pagination["page_size"]} %>
    <section id="navigation">
      <.simple_form :let={f} for={@pagination} phx-change="validate" phx-submit="save">
        <div class="space-x-4 flex flex-row items-baseline">
          <.link :if={pg > 1} href={~p"/numbers?page=#{pg - 1}&page_size=#{pg_size}"}>
            <.icon name="hero-chevron-double-left-solid" /> Prev
          </.link>
          <span :if={pg == 1} class="text-slate-400">
            <.icon name="hero-chevron-double-left-solid" /> Prev
          </span>

          <span class="sep">|</span>
          <.link href={~p"/numbers?page=#{pg + 1}&page_size=#{pg_size}"}>
            Next <.icon name="hero-chevron-double-right-solid" />
          </.link>

          <span class="sep">|</span>
          <.input field={f[:page]} label="Page" value={pg} />
          <.input field={f[:page_size]} label="Page Size" value={pg_size} />
        </div>
        <:actions>
          <.button>apply</.button>
        </:actions>
      </.simple_form>
    </section>
    """
  end
end
