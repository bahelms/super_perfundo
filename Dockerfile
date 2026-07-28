# Versions are kept in lockstep with .tool-versions and CI. The bitwalker/*
# images this used to build on are unmaintained and have no modern tags.
ARG ELIXIR_VERSION=1.20.2
ARG OTP_VERSION=28.5.0.3
ARG ALPINE_VERSION=3.22.5

FROM hexpm/elixir:${ELIXIR_VERSION}-erlang-${OTP_VERSION}-alpine-${ALPINE_VERSION} AS builder

# The hexpm images are deliberately minimal: unlike the old bitwalker image they
# ship neither a build toolchain nor node, both of which this build needs.
RUN apk add --no-cache build-base git curl nodejs npm

# Rust, for the Quarto MCTS NIF. crt-static is disabled so the cdylib links
# against the shared libgcc/libstdc++ present in the runtime image.
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --profile minimal
ENV PATH="/root/.cargo/bin:${PATH}"
ENV RUSTFLAGS="-C target-feature=-crt-static"

ENV MIX_ENV=prod

WORKDIR /app

RUN mix local.hex --force && mix local.rebar --force

# Elixir 1.19 deprecated `,` as the mix do separator in favour of `+`.
COPY mix.exs mix.lock ./
RUN mix do deps.get --only prod + deps.compile

COPY assets assets
RUN cd assets && npm install && npm run deploy

COPY . .
RUN mix do compile + phx.digest
RUN mix release


FROM alpine:${ALPINE_VERSION}

# Runtime libraries for the Rust NIF and the BEAM. libstdc++ is required by the
# newer Rust toolchain; the previous image installed only libgcc.
RUN apk add --no-cache libgcc libstdc++ ncurses-libs openssl

EXPOSE 80
ENV PORT=80 MIX_ENV=prod
WORKDIR /app

COPY --from=builder /app/_build/prod/rel/super_perfundo ./
COPY --from=builder /app/entrypoint.sh ./

CMD ["./entrypoint.sh"]
