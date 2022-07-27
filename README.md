# Super Perfundo Blog

A blog server with no database!

### Dev
Run `mix phx.gen.cert` in order to serve `https` in dev.

### Publish steps
* Move draft into /posts/published/YEAR/MONTH-DAY_TITLE.md
* Deploy
    * Announce: `Blog.get_post("name") |> Email.send_published_emails()`

### TODO
* CSS mobile: horizontal scroll for code blocks
* Usage metrics
* email signup as LiveView
* comments
- Quarto
  * Handle a draw in UI
  * Include quarto_ai crate cargo tests in Github Actions verify PR checks
  * Change cursor to hand pointer
  * Restart game button
