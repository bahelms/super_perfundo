==title==
Super perfundo on the early eve of your day

==tags==
elixir, phoenix, css

==description==
How I was inspired to create this blog and the methods I used to get it to production.

==body==
After years of thinking about writing technical blog posts, I've finally found 
the impetus to cross the finish line and actually do it. In the past, I was never sure what 
to write about. What ideas could I discuss that haven't already been discussed 
before? I enjoy reading other blogs, but I never thought of anything meaningful 
to contribute myself. Lately, though, I've found a couple things that inspired me. 

One is the fact that I've decided to create my own new programming language. 
For fun of course (I don't expect anyone else to use it). That should provide plenty of content to share, and I'll kick
that off in a future post. The other is the process of making this blog itself.
I was galvanized to make this site after reading an article from José Valim
about how [Dashbit put together its blog](https://dashbit.co/blog/welcome-to-our-blog-how-it-was-made){:target="x"}.
In this post, I'll talk about how I started with that blueprint and ended up with
what you're seeing now.

### Blog Functionality
The site is built with [Phoenix](https://www.phoenixframework.org/){:target="x"}, 
which I think is the best way to build a serverful web app in this day and 
age<a class="note-anchor" name="1'">[<sup>1</sup>](#1)</a>.
However, the main thing from that post which grabbed my attention was the fact that posts were 
served without a database. I think finding ways to avoid 
using a DB is novel and interesting, if not always practical in production. 
But it's not just reading a file and rendering it upon request. The posts 
themselves are compiled into the app, so they are already in memory! Here's the
magic:
```elixir
defmodule SuperPerfundo.Blog do
  alias SuperPerfundo.Blog.Post

  for app <- [:earmark, :makeup_elixir], do: Application.ensure_all_started(app)

  # "posts/*.md"
  paths =
    Application.compile_env(:super_perfundo, :posts_pattern)
    |> Path.wildcard()

  # @external_resource says this module is dependent on 
  # the value and will recompile if the value changes.
  posts =
    for path <- paths do
      @external_resource Path.relative_to_cwd(path)
      Post.parse!(path)
    end

  @posts Enum.sort_by(posts, & &1.date, {:desc, Date})

  def list_posts, do: @posts
end
```
It globs all the posts from wherever they're configured to be, parses them, and 
compiles them into the module. `@external_resource` tells Mix that contents 
from an external file were embedded in this module, so if they change, recompile. 
By the time the server starts, `@posts` inside `list_posts/0` has been replaced with a list of `Post` structs. 

For published posts, the date is taken from the directory and filename. 
For example, `posts/published/2020/1-1-hey.md` comes out as `January 1, 2020`. 
There's also an internal drafts feature that uses the current date at compile time. 
This way I can hand a URL to someone for proofreading before it gets published.
The posts are written in markdown and stored in version control, which makes 
developing them very enjoyable (and I don't have to leave vim!). Throw in a 
new `live_reload` pattern and you can watch your work update automatically as 
you save it.

Before I built this I had been toying with the idea of taking a [Gatsby](https://www.gatsbyjs.org/){:target="x"} tutorial and using that to generate a static site. But by using Phoenix with pre-compiled blog posts, I can take advantage of static AND dynamic features at lightning speed. Super cool. 


### Visual Design
I've always been more interested in the backend world; 
I love [PLT](https://en.wikipedia.org/wiki/Programming_language_theory){:target="x"} 
and deeper computer science topics. Making things look pretty has always been a necessary evil. 
However, no one else was going to make my blog look good. Currently, Phoenix (v1.4) 
ships with [Milligram](https://milligram.io/){:target="x"} as its CSS framework. 
I started out with that but went nowhere fast. It was a brand new 
tool for me to learn and the docs aren't great. 

I decided to bite the bullet and learn me some real CSS from scratch. Fortunately, 
the amazing company I work for, [SalesLoft](https://salesloft.com){:target="x"}, 
offers [LinkedIn Learning](https://www.linkedin.com/learning){:target="x"}. 
After taking a couple of courses, I threw out the Milligram code and designed 
the site from the ground up to be responsive and mobile friendly using only 
vanilla CSS3. It was actually a lot more fun than I thought it would be, I'm 
pretty happy with the results, and now I'm a better developer.

### Operations
The site is hosted at [Gigalixir](https://gigalixir.com/){:target="x"}, which is 
basically Heroku specifically for Elixir apps (so you can use hot upgrades, remote observer/console, etc). 
You get one app with a database that never sleeps and automatic TLS certs so you 
can use HTTPS out of the box. It's pretty easy to setup, and you can pick from 
Mix, Distillery, or Elixir Releases to deploy. I went with built-in Releases, 
so all I had to do was:
* Install the `gigalixir` CLI (with pip3)
* Create a `config/releases.exs` with some Gigalixir values
* Specify Elixir, Erlang, and Node versions in buildpacks
* `git push gigalixir master`

Gigalixir does the rest. A cool thing about Phoenix 1.4.4+ is `prod.secret.exs` uses an env var for `SECRET_KEY_BASE`, which Gigalixir generates for you, so you don't have to do anything with that file now. Since I'm not using a database there is also no need for a `DATABASE_URL`.

Next was buying a sweet domain name. The TLD `.io` is so hot right now, making it one of the more expensive ones. I picked `.tech` because I think it's a better fit in general (and it's cheap!). Then it's just a matter of adding the domain to Gigalixir and updating the CNAME. TLS certs are regenerated automatically.

At this point the site was live, but I still had to manually run tests and push to a remote. I'm too lazy for that. But I'm not too lazy to learn [GitHub Actions](https://github.com/features/actions){:target="x"}, a hip new automation platform I've been eager to play with. Thankfully, there was already a [blog post of someone doing this exact thing](https://www.mitchellhanberg.com/ci-cd-with-phoenix-github-actions-and-gigalixir/){:target="x"}. 

No one had yet made an action to deploy a Phoenix app to Gigalixir, so the author 
of that post made one himself. However, it made running migrations mandatory, 
resulting in a rollback if they failed. I didn't care about this because my site 
has no database! I figured I would enhance the existing action rather than rolling 
my own, so I made a pull request to bypass that step. Creating this blog led to 
a nice side effect of an open source contribution.

### Final Summation
This project has been a lot of fun and covered many aspects of web development. 
Had I just picked an off-the-shelf blog platform on which to publish posts, I 
may not have been as motivated to actually write. Doing it myself was way more enjoyable!
I've also been kicking around the idea of adding comments. Should I use a third party, roll my own,
or even do it at all? Leave a comment below and... oh yeah.


#### Notes
* <a name="1">[1](#1')</a>: Check out a great book, [Real-Time Phoenix](https://pragprog.com/book/sbsockets/real-time-phoenix){:target="x"}, for a look into the power this framework puts in your hands.
* The name of this article and the blog itself is taken from a mind-bending movie I've loved since first seeing it in college: [Waking Life](https://www.imdb.com/title/tt0243017/){:target="x"}.
