[
  import_deps: [:ecto, :phoenix],
  plugins: [Absinthe.Formatter, Phoenix.LiveView.HTMLFormatter],
  inputs: [
    "*.{heex,ex,exs}",
    "{mix,.formatter}.exs",
    "{config,lib,test}/**/*.{heex,ex,exs}",
    "{lib, priv}/**/*.{gql,graphql}"
  ],
  subdirectories: ["priv/*/migrations"]
]
