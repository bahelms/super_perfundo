FROM bitwalker/alpine-elixir-phoenix:1.11.4 as builder

# install Rust
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
ENV PATH $HOME.cargo/bin:$PATH
ENV RUSTFLAGS="-C target-feature=-crt-static"

# build app
ENV MIX_ENV=prod

WORKDIR /app

COPY mix.exs mix.lock ./
RUN mix do deps.get --only prod, deps.compile

COPY assets assets
RUN cd assets && npm install && npm run deploy

COPY . .
RUN mix do compile, phx.digest
RUN mix release


# start app
FROM bitwalker/alpine-elixir:1.11.4

# install runtime deps for Rust
RUN apk update --no-cache && \
    apk add --no-cache \
    libgcc

EXPOSE 80
ENV PORT=80 MIX_ENV=prod
WORKDIR /app

COPY --from=builder /app/_build/prod/rel/super_perfundo .
COPY --from=builder /app/entrypoint.sh .

CMD ["./entrypoint.sh"]
