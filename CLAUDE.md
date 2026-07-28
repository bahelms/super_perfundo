# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

Super Perfundo is a personal blog served by Phoenix with **no database**. Articles are
markdown files in `posts/` that get read and parsed at *compile time*. It also hosts a
playable Quarto game (LiveView UI, Rust NIF for the AI opponent).

## Commands

Toolchain is pinned in `.tool-versions` (Elixir 1.14.5-otp-25, Erlang 25.3.2.2); CI and
the Dockerfile mirror these versions.

```sh
mix deps.get
cd assets && npm install        # webpack pipeline, not esbuild

mix phx.gen.cert                # one-time; dev serves https on :4001 (http on :4000)
mix phx.server                  # browser must be set to allow insecure localhost

mix test
mix test test/super_perfundo/blog_test.exs:12   # single test by line
mix format --check-formatted    # CI gate

mix draft my-post-title         # scaffolds posts/drafts/M-D_my-post-title.md

cd native/quarto_ai && cargo test    # Rust tests are NOT run by CI
```

CI (`.github/workflows/verify.yml`) runs `deps.get`, `format --check-formatted`, `test`
on PRs to `master`. Merging a PR to `master` triggers `deploy.yml`: Docker build → push
to DigitalOcean registry → SSH to droplet → `docker-compose` restart.

## Architecture

### Posts are compiled into the binary

`lib/super_perfundo/blog.ex` globs the markdown files at compile time and stores the
parsed structs in `@posts` / `@drafts` module attributes. Each file is registered as an
`@external_resource`, so **editing a post recompiles `Blog`** — no runtime file reads.
`list_posts/0`, `get_post/1`, etc. just serve those attributes.

The glob patterns come from config (`:posts_pattern`, `:drafts_pattern`), which is how
tests point at the `test/posts/` fixtures instead of real content.

Posts use a custom `==field==` format (`title`, `tags`, `description`, `image`, `body`)
parsed by `SuperPerfundo.Blog.Post.parse!/1`; see `test/posts/drafts/test-draft.md` for
the canonical shape. The publish date is derived from the *file path*
(`posts/published/YEAR/MONTH-DAY_slug.md`), and the slug after `_` becomes the post id
and URL. Bodies are rendered to HTML at compile time by MDEx (comrak) with
`parse: [smart: true], render: [unsafe: true]` — `unsafe` because posts embed raw
`<div>`/`<img>` blocks, `smart` to keep the curly quotes Earmark used to apply. Code
fences get a `language-*` class and are highlighted client-side by Prism; there is no
server-side highlighter.

Images are plain relative paths (`<img src="/images/pic.png" />`). Post bodies contain
no EEx — anything `<%= ... %>` in a post is a code sample and gets escaped as such.

To publish: move the draft from `posts/drafts/` into `posts/published/YEAR/`, deploy,
then announce with `Blog.get_post("name") |> SuperPerfundo.Email.send_published_emails()`.

### Email subscriptions live in S3

There is no user table. `SuperPerfundo.EmailStorage` reads and writes a single
newline-delimited `address,timestamp` blob in the `super-perfundo` S3 bucket via ExAws.
The object name is env-specific (`:email_list` config: `email-list`, `email-list-dev`,
`email-list-test`). `Blog.Subscription` hydrates that blob into structs, mutates, and
re-serializes the whole list. Subscribe/unsubscribe are fire-and-forget — they run under
the `SuperPerfundo.EmailStorageSupervisor` `Task.Supervisor` and the controller does not
wait for the result. Mail goes out through Bamboo (SendGrid in prod, `LocalAdapter` in
dev, with the sent-email viewer mounted at `/emails` in dev only).

### Quarto game

`SuperPerfundo.Quarto.Board` encodes each piece as a 4-bit integer (shape/size/fill/color)
inside a 16-element tuple; `nil` means empty. Win detection is bitwise, not comparison —
XOR + NOT + AND across the ten winning lines finds a shared property. Read the moduledoc
in `board.ex` before touching this.

The AI is a Rustler NIF: `SuperPerfundo.Quarto.AI` declares `use Rustler, crate: "quarto_ai"`
with `:erlang.nif_error` stubs, backed by the MCTS agent in `native/quarto_ai/`. Changing
the NIF's arity or name requires matching edits on both sides of `rustler::init!` in
`native/quarto_ai/src/lib.rs`. `SuperPerfundoWeb.QuartoLive` drives the game loop and
sends itself `:ai_start` messages to keep AI moves off the mount/event path.

## Phoenix 1.5 conventions

This app predates Phoenix 1.6+ and has **not** been migrated (see the TODO in
`README.md`). Expect and preserve the old idioms rather than "modernizing" them piecemeal:

- `Phoenix.View` + `SuperPerfundoWeb.*View` modules, `.eex`/`.leex` templates (no HEEx,
  no function components, no verified routes)
- webpack + babel asset pipeline in `assets/`, driven by the `node` watcher in
  `config/dev.exs`
- `phoenix_live_view ~> 0.13`, `phoenix_html ~> 2.11`, `cowboy_telemetry` pinned only as
  a 1.5-era workaround

`config/config.exs` is compile-time; `config/runtime.exs` holds the prod-only secrets
(`SECRET_KEY_BASE`, `SENDGRID_API_KEY`, `HOST`, `PORT`, `ANALYTICS_SRC`). Values read via
`Application.compile_env/2` (post globs, `:timezone`, `:email_list`) are baked in at
compile time.
