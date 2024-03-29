==title==
Quarto, pt. 2.1: AI - Bridge Between Worlds

==tags==
elixir, rust, ai, games, quarto

==description==
Creating an artificial intelligence to fight you in Quarto. It's more fun when your
opponent isn't randomly moving. Brought to you by Rust.

==image==
rusty-engine.jpg

==body==
Now where were we? I think I need to re-read [Part 1](/articles/quarto-part-1) to remember what happened.
You might want to do the same. I'll wait.

Ah yes. The current computer opponent is pretty useless, randomly placing its pieces
and blindly picking your piece out of a hat. It would be much more interesting if it were actively
trying to destroy you in the most efficient way possible. It potentially has a lot
more brain power than you do; it shouldn't be a push over. How do we create this
monster? Well, since it's most likely going to be doing some heavy computation,
let's use [Rust](https://www.rust-lang.org/){:target="x"}! It's a lot closer to the metal than Elixir, so it
should be more performant when crunching the numbers (aka annihilating you). Also,
I like Rust and this is my blog. So there.

### Step 1: Moving our dumb AI into Rust
Now that we've put on our Architect hats and chosen Rust, we need to change our current
implementation to use it. That way we can iron out the interface between the two
languages and then focus on rewriting the rando AI into a terrifying abomination AI. 
[Rustler](https://github.com/rusterlium/rustler){:target="x"}
is the de facto way to embed Rust into Elixir as native implemented functions (NIFs).

Setting up a Rust NIF is trivial: `mix rustler.new --name quarto_ai`. This creates a new `native/quarto_ai/`
directory containing a [Cargo](https://doc.rust-lang.org/cargo/){:target="x"} project with an example NIF. Let's set it up to be a
replacement for the existing AI function. The format is fairly easy to follow:

```rust
#[rustler::nif]
fn choose_position_and_next_piece(board: SomeType, active_piece: SomeType) -> SomeType {
    ...
}

rustler::init!("Elixir.SuperPerfundo.Quarto.AI", [choose_position_and_next_piece]);
```

That defines the function and specifies where it will be accessible in Elixir.
The client usage stays the same:

```elixir
alias SuperPerfundo.Quarto.AI
{position, next_piece} = AI.choose_position_and_next_piece(board, piece)
```

We need to tell the AI module to use the function defined in the NIF. In the process,
we'll also rip out the old AI and replace it with a default implementation in the event the NIF fails:

```elixir
defmodule SuperPerfundo.Quarto.AI do
  use Rustler, otp_app: :super_perfundo, crate: "quarto_ai"

  def choose_position_and_next_piece(_board, _active_piece),
    do: :erlang.nif_error(:nif_not_loaded)
end
```

Since NIFs are just functions wrapped in an Elixir module,
we can test them normally with `mix test`. Our function returns a tuple of integers
representing the board position chosen for the given piece and the next piece
chosen for the player to place. We can test this like so (remember the return values are random):

```elixir
test "an index of the board is returned" do
  board = {nil, nil, 8, nil}
  {position, _piece} = AI.choose_position_and_next_piece(board, 10)
  assert position >= 0 && position < tuple_size(board)
  refute position == 2
end
```

We're representing the board as a tuple of integers (pieces) or nil (no piece).
Passing integers into the NIF is straightforward; they map to Rust type `i32`. But,
what about `nil`? How do we handle a tuple of mixed types? Unfortunately, the Rustler
documentation is lacking, so it took some digging and experimentation to figure out
the correct types to use. The working signature:

```rust
fn choose_position_and_next_piece(board: rustler::Term, active_piece: i32) -> (usize, i32)
```

`Term` is a Rustler type that covers all Elixir terms, meaning any type. In order
to use the board, we convert the `Term` into a vector of terms with `get_tuple`,
which returns a `Result`:

```rust
use rustler::types::tuple::get_tuple;
let positions = get_tuple(board).expect("Error getting board tuple.");
```

Now all that's left is to translate the old logic from Elixir to Rust. Which is easy if you already
know both languages :D. First, collect all the empty positions and played pieces in one swoop:

```rust
let mut empty_positions = Vec::new();
let mut played_pieces = HashSet::from([active_piece]);
for (idx, pos) in positions.iter().enumerate() {
    // Board elements are either nil or an integer.
    // In Elixir, nil is just an atom.
    // Otherwise, decode the Term into an i32.
    if pos.is_atom() {
        empty_positions.push(idx);
    } else {
        played_pieces.insert(pos.decode().expect("Position isn't an i32"));
    }
}
```

Pick one of the empty positions at random:

```rust
use rand::Rng;
let mut rng = rand::thread_rng();
let index: usize = rng.gen_range(0..empty_positions.len());
let chosen_position = empty_positions[index];
```

Choose one of the remaining pieces at random:

```rust
let all_pieces: HashSet<i32> = (0..16).collect();
let remaining_pieces: Vec<&i32> = all_pieces.difference(&played_pieces).collect();
let random_piece_idx: usize = rng.gen_range(0..remaining_pieces.len());
let chosen_piece = *remaining_pieces[random_piece_idx];
```

Make the player wait so they think they are facing a super intelligent opponent and
may be defeated at any moment:

```rust
let one_second = time::Duration::from_secs(1);
thread::sleep(one_second);
```

And finally return the results as a tuple of type `(i32, i32)`:

```rust
// a type cast is needed to turn usize (the index type) into an i32
// usize is an unsigned integer the size of the computer architecture's word (32 or 64)
(chosen_position as i32, chosen_piece)
```

Hooray! We have done it. What a sweet refactoring. Now, how the hell do we make this thing
take over the world? Well, that's gonna be a lot of work it turns out. Let's be lazy
and push that to [Part 2.2](/articles/quarto-part-2.2), where we'll figure out how to do just that! Toodles.
