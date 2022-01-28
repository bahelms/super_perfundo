==title==
If a trie falls in the forest...

==tags==
elixir, trie, data-structures, algorithms, recursion

==description==
How to construct and search a trie recursively in Elixir.

==body==
#### ...does it raise an exception?

A trie is one of those fancy data structures you may have heard nerds at
work throw around in discourse at the coffee machine. No need to feel intimidated;
it's just a type of tree! I love how easy that is to remember. I've seen it
pronounced as "try", but I like the other origin
better: a tree used for fast re**trie**val. The most popular use case I've seen for it
is to compare similar strings. For example, spell checking, auto-completion, or
language filtering.

### The trie in all its glory
<div class="flex" style="justify-content:center;">
  <img class="md-image" style="width:60%;" src="<%= img_url.("trie.png") %>" alt="My sweet trie" />
</div>

Say I start typing "ap" in a text box that provides auto-completion. Searching
the trie for those letters would show me that
"apple" and "apes" are the only possible words that can come next. The trie acts
as a source of truth, like a dictionary. Another use is searching strings for exact
matches. Maybe I want to scan for potty mouth words (shit) and their l33t versions ($h1t).
All you have to do is build up a trie and search it. Let's do just that!

### The c0d3
First, we need to think of how to model a trie in code.
