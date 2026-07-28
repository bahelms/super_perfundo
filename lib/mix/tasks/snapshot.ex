defmodule Mix.Tasks.Snapshot do
  @moduledoc """
  Renders every article and page to disk so successive runs can be diffed.

  This is the regression net for dependency and framework upgrades. `mix test`
  cannot catch a change in Earmark's output, a lost `language-*` class, or a
  layout shift -- it asserts on structure, not on rendered bytes. This task
  captures the bytes.

      MIX_ENV=dev mix snapshot tmp/snapshots/before
      # ...make a change...
      MIX_ENV=dev mix snapshot tmp/snapshots/after
      diff -ru tmp/snapshots/before tmp/snapshots/after

  For a quick check, diff `MANIFEST.txt` alone -- it lists a content hash per
  file plus a syntax-highlighting census, so one diff shows which pages moved
  and whether highlighting changed.

  Must run in `MIX_ENV=dev`: the test environment overrides `:posts_pattern` to
  the fixtures in `test/posts/`, so it would snapshot the wrong content.

  Output is normalized to stay comparable across runs -- see `scrub/1` for what
  is masked and why.
  """
  use Mix.Task

  alias SuperPerfundo.Blog

  @shortdoc "Renders all articles and pages to disk for diffing across upgrades"

  @default_dir "tmp/snapshots"

  @impl Mix.Task
  def run(args) do
    if Mix.env() == :test do
      Mix.raise(
        "mix snapshot must not run in MIX_ENV=test -- it would capture test/posts fixtures"
      )
    end

    Mix.Task.run("app.start")

    dir = List.first(args) || @default_dir
    posts = Blog.list_posts()

    # Enum.empty?/1 rather than `== []`: posts come from a compile-time module
    # attribute, so Elixir 1.18's type checker can prove `== []` is always false
    # and flags it. The check still earns its place as a guard against a
    # misconfigured :posts_pattern.
    if Enum.empty?(posts) do
      Mix.raise("no published posts found -- wrong MIX_ENV or working directory?")
    end

    File.mkdir_p!(Path.join(dir, "posts"))
    File.mkdir_p!(Path.join(dir, "pages"))

    entries =
      write_post_bodies(dir, posts) ++
        write_pages(dir, posts)

    write_manifest(dir, entries)

    Mix.shell().info("Wrote #{length(entries)} snapshots to #{dir}/")
    Mix.shell().info("Diff target: #{Path.join(dir, "MANIFEST.txt")}")
  end

  # The rendered article body, after Earmark, syntax highlighting and the
  # EEx/img_url pass. This is the highest-risk surface in an upgrade.
  defp write_post_bodies(dir, posts) do
    for post <- posts do
      body = Blog.get_post(post.id).body
      write(dir, "posts/#{post.id}.html", body)
    end
  end

  # Full pages through the real endpoint, which additionally covers the router,
  # views, templates and layout -- the surface Stage 2's HEEx migration moves.
  defp write_pages(dir, posts) do
    tags = posts |> Enum.flat_map(& &1.tags) |> Enum.uniq() |> Enum.sort()

    routes =
      [{"index", "/"}, {"about", "/about"}, {"quarto", "/quarto"}] ++
        Enum.map(posts, &{"article-#{&1.id}", "/articles/#{&1.id}"}) ++
        Enum.map(tags, &{"tag-#{safe(&1)}", "/?tag=#{URI.encode_www_form(&1)}"})

    for {name, path} <- routes do
      conn = Plug.Test.conn(:get, path) |> SuperPerfundoWeb.Endpoint.call([])

      if conn.status != 200 do
        Mix.raise("#{path} returned #{conn.status}, expected 200")
      end

      write(dir, "pages/#{name}.html", conn.resp_body)
    end
  end

  defp write(dir, rel, content) do
    content = scrub(content)
    File.write!(Path.join(dir, rel), content)
    {rel, hash(content), census(content)}
  end

  # Mask values that legitimately change on every render. Without this every
  # diff is drowned in noise and the harness is useless.
  defp scrub(html) do
    html
    # LiveView signs a fresh session/static token per render.
    |> String.replace(~r/data-phx-session="[^"]*"/, ~s(data-phx-session="SCRUBBED"))
    |> String.replace(~r/data-phx-static="[^"]*"/, ~s(data-phx-static="SCRUBBED"))
    # LiveView element ids embed a random component.
    |> String.replace(~r/id="phx-[^"]*"/, ~s(id="phx-SCRUBBED"))
    # Per-request CSRF token, in both the meta tag and every form's hidden input.
    # Both are targeted rather than matching any long attribute value, so real
    # content (meta descriptions, form values) still shows up in diffs.
    # Phoenix renders meta attributes in alphabetical order, so `content` lands
    # before `name="csrf-token"` -- hence the lookahead. Both orders are handled
    # so this keeps working if that ordering ever changes.
    |> String.replace(~r/content="[^"]*"(?=[^>]*name="csrf-token")/, ~s(content="SCRUBBED"))
    |> String.replace(~r/(name="csrf-token"[^>]*content=")[^"]*"/, "\\1SCRUBBED\"")
    |> String.replace(~r/value="[^"]*"(?=[^>]*name="_csrf_token")/, ~s(value="SCRUBBED"))
    |> String.replace(~r/(name="_csrf_token"[^>]*value=")[^"]*"/, "\\1SCRUBBED\"")
    # Makeup tags each highlighted block with a randomly-seeded group id that is
    # regenerated on every *compilation*. It is stable between renders, so three
    # identical runs will not expose it -- but any code change recompiles Blog
    # (posts are @external_resource) and every server-highlighted post would
    # then show a spurious diff. The trailing index encodes real bracket-pairing
    # structure, so keep it and mask only the random prefix.
    |> String.replace(~r/data-group-id="\d+-(\d+)"/, ~s(data-group-id="GROUP-\\1"))
    # QuartoLive.mount/3 does a random coin toss, so the copy differs per render.
    |> String.replace(~r/(You|Your opponent) won the coin toss[^<]*/, "COIN-TOSS-SCRUBBED")
  end

  # Counts the two code-block forms the pipeline can emit, so a highlighting
  # regression is visible from the manifest alone:
  #   makeup  -> highlighted server-side by ExDoc.Highlighter
  #   prism   -> left with a language-* class for client-side Prism
  defp census(content) do
    makeup = length(Regex.scan(~r/class="[^"]*makeup/, content))
    prism = length(Regex.scan(~r/class="[^"]*language-/, content))
    pre = length(Regex.scan(~r/<pre><code/, content))
    "pre=#{pre} makeup=#{makeup} prism=#{prism}"
  end

  defp write_manifest(dir, entries) do
    lines =
      entries
      |> Enum.sort_by(fn {rel, _, _} -> rel end)
      |> Enum.map(fn {rel, hash, census} ->
        String.pad_trailing(rel, 44) <> " " <> hash <> "  " <> census
      end)

    header = [
      "# mix snapshot manifest",
      "# elixir=#{System.version()} otp=#{System.otp_release()}",
      "# files=#{length(entries)}",
      ""
    ]

    File.write!(Path.join(dir, "MANIFEST.txt"), Enum.join(header ++ lines, "\n") <> "\n")
  end

  defp hash(content) do
    :crypto.hash(:sha256, content) |> Base.encode16(case: :lower) |> binary_part(0, 12)
  end

  defp safe(tag), do: String.replace(tag, ~r/[^a-zA-Z0-9._-]/, "_")
end
