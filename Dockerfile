FROM elixir:1.18-otp-27-slim

WORKDIR /app

RUN apt-get update && \
    apt-get install -y ca-certificates iputils-ping curl dnsutils git build-essential && \
    rm -rf /var/lib/apt/lists/*

RUN mix local.hex --force && \
    mix local.rebar --force

COPY mix.exs mix.lock ./

ENV MIX_ENV=dev

RUN mix deps.get

COPY . .

RUN mix deps.compile && \
    mix compile

EXPOSE 4000

CMD ["sh", "-c", "mix ecto.create && mix ecto.migrate && mix run --no-halt"]