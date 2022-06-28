==title==
Quarto, pt. 2.1: The AI

==tags==
elixir, rust, ai, games

==description==
Creating an artificial intelligence to be fight you in Quarto. It's more fun when your
opponent isn't randomly moving. Brought to you by Rust.

==image==
rusty-engine.jpg

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

### Step 1: Moving our dumb AI into Rust
Now that we've put on our Architect hats and chosen Rust, we need to change our current
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

Since NIFs are just functions wrapped in an Elixir module,
we can test them normally with `mix test`. Our function returns a tuple of integers
representing the position on the board the AI placed the active piece and the next piece
chosen for the player to place. We can test this like so (remember the return values are random):

    test "an index of the board is returned" do
      board = {nil, nil, 8, nil}
      {position, _piece} = AI.choose_position_and_next_piece(board, 10)
      assert position >= 0 && position < tuple_size(board)
    end

We're representing the board as a tuple of integers (pieces) or nil (no piece).
Passing integers into the NIF is straightforward; they map to `i32`. However,
I was unsure how to handle the tuple. And `nil`. Unfortunately, the Rustler
documentation is lacking so it took some digging and experimentation to figure out
the correct types to use. The working signature:

    fn choose_position_and_next_piece(board: rustler::Term, active_piece: i32) -> (usize, i32)

`Term` is a Rustler type that covers all Elixir terms, meaning any type. In order
to use the board, convert the `Term` into a vector of terms with `get_tuple`, which returns a `Result`:

    use rustler::types::tuple::get_tuple;
    let positions = get_tuple(board).expect("Error getting board tuple.");

All that's left is to translate the old logic from Elixir to Rust. Which is easy if you already
know both languages. :D. First, collect all the empty positions and played pieces in one swoop:

    let mut empty_positions = Vec::new();
    let mut current_pieces = HashSet::from([active_piece]);
    for (idx, pos) in positions.iter().enumerate() {
        // Board elements are either nil or an integer.
        // In Elixir, nil is an atom.
        // Otherwise, decode the Term into an i32.
        if pos.is_atom() {
            empty_positions.push(idx);
        } else {
            current_pieces.insert(pos.decode().expect("Position isn't an i32"));
        }
    }

Pick one of the empty positions at random:

    use rand::Rng;
    let mut rng = rand::thread_rng();
    let index: usize = rng.gen_range(0..empty_positions.len());
    let chosen_position = empty_positions[index];

Choose one of the remaining pieces at random:

    let all_pieces: HashSet<i32> = (0..16).collect();
    let remaining_pieces: Vec<&i32> = all_pieces.difference(&current_pieces).collect();
    let random_piece_idx: usize = rng.gen_range(0..remaining_pieces.len());
    let chosen_piece = *remaining_pieces[random_piece_idx];

Make the player wait so they think they are facing a super intelligent opponent and
may be defeated at any moment:

    let one_second = time::Duration::from_secs(1);
    thread::sleep(one_second);

And finally return the results as a tuple of type `(usize, i32)`:

    // usize is the default type of indexes in Rust
    // it's an unsigned integer the size of the computer architecture's word (32 or 64)
    (chosen_position, chosen_piece)

We have done it! What a sweet refactoring. Now how the hell do we make this thing
take over the world? Well, that's gonna be a lot of work it turns out. Let's be lazy
and push that to [Part 2.2!](/) (not finished yet!)
