==title==
Quarto, pt. 2: The AI

==tags==
elixir, rust, ai, games

==description==
Creating an artificial intelligence to be fight you in Quarto. It's more fun when your
opponent isn't randomly moving. Brought to you by Rust.

==image==
trie.png

==body==
Now where were we? I think I need to read part 1 again to see what happened.
You might want to, as well: [Part 1](/articles/quarto-part-1).

Ah yes. The current computer opponent is pretty useless, randomly putting its pieces
down and picking your piece out of a hat blindfolded. It would be much more interesting if it were actively
trying to destroy you in the most efficient way possible. It potentially has a lot
more brain power than you do; it shouldn't be a push over. How do we create this
monster? Since this thing is most likely going to be doing some heavy computation,
I've decided to code it in [Rust](https://www.rust-lang.org/). It's a lot closer to the metal than Elixir, so it
should be more performant when crunching the numbers (aka annihilating you). Also,
I like Rust and this is my blog. So there.

### Step 1: Moving the dumb AI into Rust
Now that we've put on our Architect hat and chosen Rust, we need to change our current
implementation to use it. That way we can iron out the interface between the two
languages and then focus on rewriting the rando AI into a crushing AI. [Rustler](https://github.com/rusterlium/rustler)
is the de facto way to embed Rust into Elixir as native implemented functions (NIFs).

Setting up a Rust NIF is trivial: `mix rustler.new --name quarto_ai`. This creates a new `native/quarto_ai/`
directory containing a [Cargo](https://doc.rust-lang.org/cargo/) project with an example NIF. Let's set it up to be a
replacement for the existing AI function. The format is fairly easy to follow:



    #[rustler::nif]
    fn choose_position_and_next_piece(board: SomeType, active_piece: SomeType) -> SomeType {
      ...
    }

    rustler::init!("Elixir.SuperPerfundo.Quarto.AI", [choose_position_and_next_piece]);

That defines the function and specifies where it will be accessible from Elixir.
It's current usage stays the same:

    alias SuperPerfundo.Quarto.AI
    {position, next_piece} = AI.choose_position_and_next_piece(board, piece)

In the AI module, you need to tell it to use the function defined in the NIF. We'll
also rip out the rando AI and replace it with a default implementation in the event the NIF fails:

    defmodule SuperPerfundo.Quarto.AI do
      use Rustler, otp_app: :super_perfundo, crate: "quarto_ai"

      def choose_position_and_next_piece(_board, _active_piece),
        do: :erlang.nif_error(:nif_not_loaded)
    end

Next, we translate the old logic from Elixir to Rust. Which is easy if you already
know both languages. :D

Unfortunately, the documentation is lacking so it took some fiddling to figure

### Step 2: Creating a smart AI
