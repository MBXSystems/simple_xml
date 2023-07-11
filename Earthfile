VERSION 0.5


test:
    FROM +setup-base
    COPY mix.exs mix.lock .formatter.exs ./
    RUN mix deps.get

    RUN MIX_ENV=test mix deps.compile
    COPY --dir lib test ./

    RUN mix deps.get --only test
    RUN mix deps.compile
    RUN mix test

lint:
    FROM +test
    RUN mix deps.get
    RUN mix deps.unlock --check-unused
    RUN mix compile --warnings-as-errors
    RUN mix lint

setup-base:
    ARG ELIXIR_BASE=1.15.2-erlang-26.0.2-ubuntu-jammy-20230126
    FROM hexpm/elixir:$ELIXIR_BASE
    RUN apk add --no-progress --update git build-base
    RUN mix local.rebar --force
    RUN mix local.hex --force
    ENV ELIXIR_ASSERT_TIMEOUT=10000
    WORKDIR /src/simple_xml

