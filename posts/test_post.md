==title==
hey
==body==
Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed egestas turpis leo, quis posuere quam luctus et. Integer dignissim aliquet tortor in vulputate. Nunc ut feugiat dolor. Nulla pretium magna non nunc ultricies maximus. Duis eget scelerisque sapien. In sit amet est in felis lobortis aliquam. Nunc facilisis augue at nisl facilisis ultrices. Integer nec leo eleifend, interdum dui vel, feugiat massa. Aenean quam turpis, lacinia ut tellus tincidunt, gravida sodales risus. Proin dui dolor, consequat eget massa vel, gravida pretium orci. Vivamus mollis, mi sit amet sodales placerat, felis nulla porttitor risus, non pharetra nunc tortor non tellus.

Donec bibendum tellus non eleifend accumsan. Nunc nec erat nec nulla convallis maximus a vitae quam. Suspendisse viverra sodales risus. Suspendisse potenti. Fusce leo dui, ornare non orci eget, ornare ullamcorper sem. Cras ut semper nibh, non sagittis velit. Nam pretium elit nec dolor aliquam malesuada. Suspendisse mollis sollicitudin sodales. Etiam accumsan hendrerit enim, at varius est maximus in. Mauris id dui sit amet neque blandit tempus. Donec mollis, lacus vitae commodo sodales, elit velit vehicula mi, eget aliquet felis dolor id diam. Morbi id porttitor enim. Quisque nec nulla vel mi dignissim imperdiet at nec metus. Nam euismod consectetur hendrerit. Mauris ac ipsum id mauris sagittis tincidunt.

```
defmodule SuperPerfundo.Blog do
  alias SuperPerfundo.Blog.Post

  for app <- [:earmark, :makeup_elixir], do: Application.ensure_all_started(app)

  paths =
    Application.compile_env(:super_perfundo, :posts_pattern)
    |> Path.wildcard()

  posts =
    for path <- paths do
      @external_resource Path.relative_to_cwd(path)
      Post.parse!(path)
    end

  @posts Enum.sort_by(posts, & &1.date, {:desc, Date})

  def list_posts, do: @posts

  def list_posts(for_tag: tag) do
    for post <- @posts, tag in post.tags, do: post
  end

  def get_post(id), do: Enum.find(@posts, &(&1.id == id))
end
```

Donec pharetra est nisi, vel facilisis metus iaculis quis. Donec consequat ipsum metus, vel finibus enim rutrum quis. Nunc a mauris dui. Aenean velit mi, pellentesque sit amet velit et, lacinia pharetra dui. Donec ac ornare magna, vitae fringilla lectus. Phasellus eleifend justo et laoreet euismod. In sed ante odio.

Quisque convallis erat ex, ac molestie dui dapibus euismod. Pellentesque eleifend, nibh eget finibus vestibulum, mauris ligula viverra ex, sed imperdiet lorem erat eu urna. Aliquam lorem enim, fermentum ut nulla nec, efficitur pellentesque nibh. Aenean sit amet purus eros. Etiam magna ipsum, aliquam nec placerat vel, volutpat sit amet dui. Pellentesque posuere nisi nec aliquet convallis. Vestibulum ultricies erat in felis lacinia, vel tempor nunc semper. Maecenas mattis congue malesuada.

Mauris ut quam tempus, cursus diam non, dapibus massa. Proin condimentum condimentum metus. Sed eleifend mauris id purus dapibus dictum. Vivamus posuere ipsum quis nunc lobortis suscipit. Proin ultrices varius massa non condimentum. Fusce sed congue magna. Curabitur a mollis tortor, eu consectetur massa. Sed imperdiet risus id feugiat venenatis. Sed at eleifend odio. Etiam at massa sodales, dapibus libero ut, vehicula neque. Etiam laoreet velit nec libero eleifend dapibus. Morbi a laoreet ipsum. In cursus lacus neque, sed iaculis nunc aliquam nec. Pellentesque cursus erat eget eleifend tincidunt.
==description==
go away
==tags==
test
