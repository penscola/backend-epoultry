[
  import_deps: [:ecto, :phoenix],
  plugins: [Absinthe.Formatter],
  inputs: [
    "{mix,.formatter}.exs",
    "{config,lib,test}/**/*.{ex,exs}",
    "{lib, priv}/**/*.{gql,graphql}"
  ],
  subdirectories: ["priv/*/migrations"]
]
