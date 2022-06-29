FROM bitwalker/alpine-elixir-phoenix:1.11.4 as builder

WORKDIR /app
ENV MIX_ENV=prod

COPY mix.exs mix.lock ./
RUN mix do deps.get --only prod, deps.compile

COPY assets assets
RUN cd assets && npm install && npm run deploy

COPY . .
RUN mix do compile, phx.digest
RUN mix release


FROM bitwalker/alpine-elixir:1.11.4

EXPOSE 80
ENV PORT=80 MIX_ENV=prod
WORKDIR /app

COPY --from=builder /app/_build/prod/rel/super_perfundo .
COPY --from=builder /app/entrypoint.sh .

CMD ["./entrypoint.sh"]
