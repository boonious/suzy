# Suzy

Number streams ("数溪 - ShùXī" in Chinese): experimenting with Elixir / Phoenix
stacks for displaying, decorating, streaming billions of numbers via both JSON API and UI.

Current feature: modulo-N deduction on number streams with basic caching.

## Usage
To start your Phoenix server:

  * Run `mix setup` to install and setup dependencies
  * Start Phoenix endpoint with `mix phx.server` or inside IEx with `iex -S mix phx.server`

Then visit the following from your browser:
- [`localhost:4000/numbers`](http://localhost:4000/numbers)
- [`localhost:4000/api/numbers`](http://localhost:4000/api/numbers)

### Querying
Both the UI and API uses the following `GET` query params:
- `page`, default `1`
- `page_size`, default `100`
- `attrs[]` multiple of `mod_n` and `cache_get`, e.g.  `?attrs[]=cache_get&attrs[]=mod_3&attrs[]=mod_5`

### Caching
To cache a number in the app in-memory cache (basic GenServer):
-  `POST` to [`localhost:4000/api/numbers/:number`](http://localhost:4000/numbers/:number) where `:number` is the number, using `attrs[]` params described above:
  - `localhost:4000/api/numbers/3?attrs[]=mod_3` 
  - `localhost:4000/api/numbers/2?attrs[]=mod_3` <- error, as caching is only for valid mod-n numbers
- UI: select `cache` checkbox and click on the star icon of a number

## Design
The app is mainly underpinned by the [Phoenix Framework](https://www.phoenixframework.org)
and uses [Phoenix components](https://hexdocs.pm/phoenix/components.html#function-components) for 
a basic UX.

The `Decorator` design pattern is used in the backend design to perform various modulo-n number 
deductions which are runtime / dynamically composable as demonstrated in the API/UI, via the `attrs[]`
params described above. For example, the following performs `mod_3`, `mod_4`, `mod_5` deduction:

- `localhost:4000/api/numbers?attrs[]=mod_3&attrs[]=mod_4&attrs[]=mod_5`

The deduction logic all implements a common/base number behaviour (the `Number.deduce/1` callback). 
The logic is executed from a composable runtime pipeline or stack. The same
mechanism is also used for number caching and fetching numbers from cache as well:

```ex
# composable stack performing modulo-n deduction
[Numbers.Mod3, Numbers.Mod5]

# post-deduction caching
[Numbers.Mod3, Numbers.Mod5, Numbers.CachePut]

# fetch from cache first, a hit will bypass the subsequent deductions
[Numbers.CacheGet, Numbers.Mod3, Numbers.Mod5]
```

Further details:
- https://github.com/boonious/suzy/pull/1
- https://github.com/boonious/suzy/pull/2
- https://github.com/boonious/suzy/pull/3

### Example Rust client for the API

```rust
cd rust_client

// Lists modulo-n numbers 
cargo run GET  "http://localhost:4000/api/numbers?attrs[]=cache_get&attrs[]=mod_3&attrs[]=mod_5"

// Cache a modulo-n number
cargo run POST  "http://localhost:4000/api/numbers/3?&attrs[]=mod_3"
```

GET Response:

```
suzy_client % cargo run "get" "http://localhost:4000/api/numbers?attrs[]=cache_get&attrs[]=mod_3&attrs[]=mod_5"
    Finished dev [unoptimized + debuginfo] target(s) in 0.11s
    Running `target/debug/suzy_client get 'http://localhost:4000/api/numbers?attrs[]=cache_get&attrs[]=mod_3&attrs[]=mod_5'`
1
2
3 Fizz cached
4
5 Buzz
6 Fizz
7
8
9 Fizz
10 Buzz
11
12 Fizz
13
14
15 FizzBuzz
16
17
18 Fizz
...
```