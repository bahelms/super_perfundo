# Super Perfundo Blog

A blog server with no database!

### Dev
Run `mix phx.gen.cert` in order to serve `https` in dev.

### TODO
* CSS mobile: horizontal scroll for code blocks
* email signup as LiveView
* comments

Publish steps
* Move draft into /posts/published/YEAR/MONTH_DAY_TITLE.md
* Deploy
* Exec `_build/prod/rel/super_perfundo/bin/super_perfundo eval "SuperPerfundo.Release.send_new_article_emails"`
