FROM bitwalker/alpine-elixir-phoenix:1.11.4 as builder
FROM rust:1-slim as rust

WORKDIR /app
ENV MIX_ENV=prod \
    RUSTUP_HOME=/usr/local/rustup \
    CARGO_HOME=/usr/local/cargo \
    PATH=/usr/local/cargo/bin:$PATH

COPY mix.exs mix.lock ./
RUN mix do deps.get --only prod, deps.compile

COPY assets assets
RUN cd assets && npm install && npm run deploy

COPY . .
COPY --from=rust /usr/local/cargo /usr/local/cargo
COPY --from=rust /usr/local/rustup /usr/local/rustup
RUN mix do compile, phx.digest
RUN mix release


FROM bitwalker/alpine-elixir:1.11.4

EXPOSE 80
ENV PORT=80 MIX_ENV=prod
WORKDIR /app

COPY --from=builder /app/_build/prod/rel/super_perfundo .
COPY --from=builder /app/entrypoint.sh .

CMD ["./entrypoint.sh"]
