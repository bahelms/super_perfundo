# Super Perfundo Blog

A blog server with no database!

### Dev
Run `mix phx.gen.cert` in order to serve `https` in dev.

### Publish steps
* Move draft into /posts/published/YEAR/MONTH-DAY_TITLE.md
* Deploy
    * In `ps:remote_console`, `Blog.get_post("name") |> Email.send_published_emails()`

### TODO
* CSS mobile: horizontal scroll for code blocks
* email signup as LiveView
* comments
- Quarto
  * Change cursor to hand pointer
  * Restart game button
  * Actual AI
