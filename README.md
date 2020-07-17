# Super Perfundo Blog

A blog server with no database!

### Dev
Run `mix phx.gen.cert` in order to serve `https` in dev.

### Publish steps
* Move draft into /posts/published/YEAR/MONTH_DAY_TITLE.md
* Deploy
    * In `ps:remote_shell`, `Blog.get_post("name") |> Email.send_published_emails()`

### TODO
* CSS mobile: horizontal scroll for code blocks
* email signup as LiveView
* comments
- Quarto
  * Instructions
  * Restart game button
  * Coin toss to see who starts
  * Actual AI
