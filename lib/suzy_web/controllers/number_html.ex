defmodule SuzyWeb.NumberHTML do
  use SuzyWeb, :html

  @badge_colours %{
    mod_2: "bg-yellow-200",
    mod_3: "bg-yellow-300",
    mod_4: "bg-yellow-400",
    mod_5: "bg-orange-200",
    mod_6: "bg-orange-300",
    mod_7: "bg-orange-400",
    mod_8: "bg-indigo-200",
    mod_9: "bg-indigo-300",
    mod_10: "bg-indigo-400"
  }

  embed_templates "number_html/*"

  attr :num, :map, required: true
  attr :caching, :boolean, default: false

  def number(assigns) do
    ~H"""
    <% id = "num-#{@num[:value]}"
    attrs = for attr <- @num[:attrs], do: {:"attrs[]", attr}
    fav = "/numbers/#{@num[:value]}?" <> (attrs |> URI.encode_query()) %>

    <div id={id} class="items-baseline p-4 rounded-lg shadow-lg bg-slate-100 text-left">
      <%= @num[:value] %>
      <.link :if={@num[:attrs] != [] and not @num[:cached] and @caching} href={fav} method="post">
        <.icon class="cache_icon h-4 w-4 text-slate-500 text-right" name="hero-star" />
      </.link>

      <span :if={@num[:attrs] != [] and @num[:cached] and @caching}>
        <.icon class="cache_icon h-4 w-4 text-slate--700 text-right" name="hero-star-solid" />
      </span>

      <br :if={@num[:attrs] != []} />
      <div :if={@num[:attrs] != []} class="text-right"><.attrs_badge attrs={@num[:attrs]} /></div>
    </div>
    """
  end

  attr :attrs, :list, required: true

  def attrs_badge(assigns) do
    assigns = Map.put(assigns, :badge_colours, @badge_colours)

    ~H"""
    <% bg =
      if length(@attrs) == 1 and @badge_colours[hd(@attrs)],
        do: @badge_colours[hd(@attrs)],
        else: "bg-green-300"

    class = "badge #{bg} text-sm font-medium px-0.5 py-0.5" %>

    <span :if={length(@attrs) == 1} class={class}><%= hd(@attrs) %></span>
    <span :if={length(@attrs) > 1} class={class}>
      <%= "mod" <> (@attrs |> Enum.map_join(",", &String.slice("#{&1}", 3..-1))) %>
    </span>
    """
  end

  attr :nums, :list, required: true
  attr :caching, :boolean, default: false

  def numbers_grid(assigns) do
    ~H"""
    <section
      id="numbers-grid"
      class="grid grid-cols-10 gap-4 font-mono text-sm text-center font-bold rounded-lg"
    >
      <.number :for={num <- @nums} num={num} caching={@caching} />
    </section>
    """
  end

  attr :attrs, :list, required: true
  attr :pagination, :map, required: true
  attr :caching, :boolean, default: false

  def navigation(assigns) do
    ~H"""
    <% mod_range = Application.fetch_env!(:suzy, :modulo_range)
    mod_opts = mod_range |> Enum.map(&("mod_" <> "#{&1}")) |> Enum.map(&{&1, &1 in @attrs}) %>

    <section id="navigation">
      <.simple_form :let={f} for={@pagination} phx-change="validate" phx-submit="save">
        <div class="space-x-4 flex flex-row items-baseline">
          <.pagination
            pg={@pagination["page"]}
            pg_size={@pagination["page_size"]}
            f={f}
            attrs={@attrs}
          />

          <.input name="attrs[]" type="checkbox" value="cache_get" checked={@caching} label="cache" />
          <.input
            :for={{mod, checked} <- mod_opts}
            name="attrs[]"
            type="checkbox"
            value={mod}
            label={mod}
            checked={checked}
          />
        </div>
        <:actions>
          <.button>apply</.button>
        </:actions>
      </.simple_form>
    </section>
    """
  end

  attr :f, :map
  attr :attrs, :list, required: true
  attr :pg, :integer, required: true
  attr :pg_size, :integer, required: true

  def pagination(assigns) do
    ~H"""
    <% attrs = for attr <- @attrs, do: {:"attrs[]", attr}
    pg_size = {:page_size, @pg_size}
    prev = "/numbers?" <> (([{:page, @pg - 1}, pg_size] ++ attrs) |> URI.encode_query())
    next = "/numbers?" <> (([{:page, @pg + 1}, pg_size] ++ attrs) |> URI.encode_query()) %>

    <.link :if={@pg > 1} href={prev}>
      <.icon name="hero-chevron-double-left-solid" /> Prev
    </.link>
    <span :if={@pg == 1} class="text-slate-400">
      <.icon name="hero-chevron-double-left-solid" /> Prev
    </span>

    <span class="sep">|</span>
    <.link href={next}>Next <.icon name="hero-chevron-double-right-solid" /></.link>

    <span class="sep">|</span>
    <.input field={@f[:page]} label="Page" value={@pg} />
    <.input field={@f[:page_size]} label="Page Size" value={@pg_size} />
    """
  end
end
