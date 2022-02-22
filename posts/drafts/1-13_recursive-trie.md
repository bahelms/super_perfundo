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

### The plan
First, we need to think of how to model a trie in code. A trie is most commonly represented
as a node pointing to an array of child nodes. This is no binary tree. However,
this seemed inefficient to me. On every search, each array of nodes would also need to
be searched. Is there a way to avoid this O(n) cost for every child collection?
Maybe even get an O(1) operation? By George, there is! **The map** (*or hash, dictionary,
associative array; wherever you're from*).

In our example trie from above, instead of nodes of arrays:

    root -> [a -> [p -> [p -> [l -> [e]], e -> [s]]]]
we could say a node is a map of breadth-level letters pointing to other maps.

        {a,    b,  m}
         |     |   |
        {p}   {e} {m}
         |     |   |
      {p,  e} {e} {n}
       |   |   |   |
      {l} {s} {r} {k}
       |           |
      {e}       {e,  s}
                 |
                {y}
Essentially, when a letter branches, it points to a single map with the keys
being all child letters and their values being more maps. This actually allows us
to do away with a root node entirely, and provides O(1) access to a node's children.
It's also very recursion friendly.

### The c0d3
