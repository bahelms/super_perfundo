==title==
If a trie falls in the forest...

==tags==
elixir, trie, data-structures, algorithms, recursion

==description==
How to construct and search a trie recursively in Elixir.

==body==
...does it raise an exception?

A trie is one of those fancy data structures you may have heard smart people at
work through around at the coffee machine. It's a type of tree! I love how easy
that is to remember. I've seen it pronounced as "try", but I like the other origin
better: a tree used for fast re**trie**val. The most popular use case I've seen for it
is to compare similar strings. For example, a spell checker or language filter. 
Let's dig in.

<div class="flex" style="justify-content:center;">
  <img class="md-image" style="width:60%;" src="<%= img_url.("trie.png") %>" alt="My sweet trie" />
</div>
