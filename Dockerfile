### build variables ###
ARG ELIXIR_BUILDER_IMAGE="hexpm/elixir:1.13.4-erlang-25.0.2-alpine-3.16.0"

### elixir processor section: build ###
FROM ${ELIXIR_BUILDER_IMAGE}

# install build dependencies
RUN apk add git

# prepare build dir
COPY . /app
WORKDIR /app
# set build ENV
ENV MIX_ENV="dev"
# install mix dependencies
COPY mix.exs mix.lock ./
RUN mix local.hex --force && \
    mix local.rebar --force
RUN mix deps.get
# copy compile-time config files before we compile dependencies
# to ensure any relevant config change will trigger the dependencies
# to be re-compiled.
COPY config config
COPY lib lib
RUN mix deps.compile
# compile the release
RUN mix compile
RUN mix release --overwrite

CMD /app/_build/dev/rel/smart_farm start