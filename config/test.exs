import Config

config :suzy,
  cache: Suzy.CacheMock,
  modulo_range: 2..5

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :suzy, SuzyWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "pDaTXVP7EFXFBDP0p9vTcvDRoJ5v8H4Q9/mdmudDaQm21xnDd8gTW1NnYscD5dkl",
  server: false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime
