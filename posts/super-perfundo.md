==title==
Super perfundo on the early eve of your day

==tags==
elixir, phoenix, css

==description==
TBD

==body==
After years of thinking about writing technical blog posts, I've finally found 
the impetus to cross the finish line and actually do it. I was never sure what 
to write about. What ideas could I discuss that haven't already been discussed 
before? I enjoy reading other blogs, but I never thought of anything meaningful 
to contribute myself. Lately, though, I've found a couple things that inspired me. 

One is the fact that I've decided to create my own new programming language. 
For fun of course. That should provide plenty of content to share, and I'll kick
that off in the next post. The other is the process of making the blog server itself.
I was massively inspired to make this site after reading a post from José Valim
about how [Dashbit](https://dashbit.co){:target="x"} put together its blog: 
<https://dashbit.co/blog/welcome-to-our-blog-how-it-was-made>{:target="x"}.
In my post, I'll talk about how I started with that blueprint and ended up with
what you're seeing now.

### Functionality
The site is built with [Phoenix](https://www.phoenixframework.org/){:target="x"}, 
which I think is the best way to build a serverful web app in this day and age. 
However, the main thing that grabbed my attention was the fact that posts were 
served without a database. I think finding ways to avoid 
using a DB is novel and interesting, if not always practical in production. 
But it's not even just reading a file and rendering it upon request. The posts 
themselves are compiled into the app, so they are already in memory! Here's the
magic:
```
defmodule SuperPerfundo.Blog do
  alias SuperPerfundo.Blog.Post

  for app <- [:earmark, :makeup_elixir], do: Application.ensure_all_started(app)

  # "posts/*.md"
  paths =
    Application.compile_env(:super_perfundo, :posts_pattern)
    |> Path.wildcard()

  # @external_resource says this module is dependent on 
  # the value and will recompile if it changes.
  posts =
    for path <- paths do
      @external_resource Path.relative_to_cwd(path)
      Post.parse!(path)
    end

  @posts Enum.sort_by(posts, & &1.date, {:desc, Date})

  def list_posts, do: @posts
end
```

I had been toying with the idea of taking a [Gatsby](https://www.gatsbyjs.org/){:target="x"} tutorial and using that to generate a static site. But by using Phoenix with pre-compiled blog posts, you can enjoy static AND dynamic features at lightning speed.  Super cool. The posts are also written in markdown and stored in version control, which makes developing them very enjoyable (and I don't have to leave vim!). Throw in a new `live_reload` pattern and you can watch your post update automatically as you write it.

### Design

### Deployment
