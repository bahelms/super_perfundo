# Super Perfundo Blog

A blog server with no database!

### Dev
Run `mix phx.gen.cert` in order to serve `https` in dev.

### Publish steps
* Move draft into /posts/published/YEAR/MONTH-DAY_POST-TITLE.md
* Deploy
    * Announce: `Blog.get_post("name") |> Email.send_published_emails()`

### TODO
* Usage metrics
* email signup as LiveView
- Quarto
  * Handle a draw in UI
  * Include quarto_ai crate cargo tests in Github Actions verify PR checks
  * Change cursor to hand pointer
  * Restart game button
