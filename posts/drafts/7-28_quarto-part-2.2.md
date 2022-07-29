==title==
Quarto, pt. 2.2: The AI - Behind The Curtain

==tags==
elixir, rust, ai, games, quarto, algrithms

==description==
How to actually write this silly robot. It's fun. I promise!

==image==
monte-carlo.png

==body==
We've made it! I'm not gonna lie, this part was tough. But, Oh! The things
you can accomplish with grit, determination, perseverance, tenacity, all that.
If you've stumbled on this post and haven't read the precursors, you're not going
to have any idea what I talking about. Start here: [Part 1](/articles/quarto-part-1).

### Step 1: The Algorithm - Monte Carlo Tree Search
Because machine learning is fascinating and games are fun, I started reading
[Deep Learning and the Game of Go](https://www.manning.com/books/deep-learning-and-the-game-of-go){:target="x"}.
I didn't realize it at the time, but the first part of the book would enlighten me
on how to build an AI for Quarto. It goes over traditional board game engine techniques like minimax,
alpha beta pruning, and Monte Carlo tree search. I thought using deep learning for Quarto right out the gate
would be overkill, so the conventional route seemed the best place to start.
The problem with minimax/alpha-beta pruning is that they depend on a heuristic function
that can examine the state of the game and concretely tell you which side is doing better.
For Quarto, and even tic-tac-toe for that matter, I had no idea how to suss out an advantage
just by looking at the board and remaining pieces (apart from next-move-wins).
However, Monte Carlo tree search was designed not to need such a heuristic.
I can solve the problem by avoiding it. Perfect!

Similar to reinforcement learning, MCTS takes a given game state and plays out
as many moves as possible within a given time limit. The moves are randomly selected
each turn, and the one that ends up with the highest win rate is chosen. It would
take too long to see every possibility, so processing is constrained by number of iterations
or a length of time. Therefore, even with the odds in your favor, you still might lose the bet.
This is why it was named after Monte Carlo, a place world famous for gambling.

Here's my algorithm that guided me through the coding process:

- create tree (root node) for given game state
- start a round:
    - pick a leaf node
    - randomly place the active piece and choose the next piece
    - add new child node with this game state
    - execute rollout (simulate game from this node to see who wins)
    - record the win in this node
    - walkup all node ancestors and update their win counts
- Set this to a certain number of rounds
    - Once limit is reached, select the child node of the root that has the highest win rate

### Step B: The Codes

#### Translating the algorithm to code
Remember this line?

```elixir
{position, next_piece} = AI.choose_position_and_next_piece(board, piece)
```

That's called in Elixir after the user picks the piece for the AI. With the rustler
NIF in place, the definition of that function winds up here, showing the new AI code:

```rust
fn choose_position_and_next_piece(board: Term, active_piece: i32) -> (i32, i32) {
    let board = convert_term_to_board(board);
    let game = GameState::new(board, active_piece, AGENT);
    let agent = Agent::new(3000, 1.5);
    let selected_move = agent.select_move(game);
    (selected_move.position, selected_move.next_piece)
}
```

Converting the Term into an array of i32s remains the same. However, now we pass it
to a game state struct. An `Agent` is created, which takes the game state and picks
the best move for the AI (`AGENT`). Alright! We're done. I hope you enjoyed...oh,
you want to see what the agent does? Fine.

```rust
pub struct Agent {
    num_rounds: i32,
    temperature: f64,
}
```

It takes the number of game simulation rounds and the temperature (more on that later).
The number of rounds is our time constraint. More rounds generally increase the accuracy,
but also the time the user spends watching a spinny thing. Inside `select_move` we have:

```rust
pub fn select_move(&self, game: GameState) -> Move {
    let root = NodeBuilder::new(game).build();
```

And there we have the fundamental headache that must be dealt with: what is a node?

#### Rc&lt;RefCell> Hell - writing a cyclical tree in Rust
Rust by default does not like it when you create objects that reference each other.
In our tree, a node needs to point to an array of child nodes. It's totally fine for the parent
to own the children (until they're 18). The problem is when the child nodes need to
reference their parent (children can't also own their parents, but grandparents are
expected to borrow the children! Ok I'm done). If the child owns a reference to the
parent but is also value owned by the parent, neither can ever be dropped!

I spent several painful iterations on how to get past this paradox and settled
on using `Rc`, `Weak`, and `RefCell`. It definitely adds mental overhead and basically
is a way to sneak around Rust's natural ownership/borrowing mechanics. `Rc` wraps a value and
keeps track of how many references point to it: `Rc::new(node)`. You can access it's wrapped data
as usual, but it's immutable. Calling `clone` on it creates a new reference and increases
the count. It's only dropped once the count is zero. We're going to be adding children
to a node's array, so it will need to be mutable. That's were `RefCell` comes in.
It allows an `Rc`'s value to be mutable. `Rc::new(RefCell::new(node))`.
Now to access that value use `borrow` and `borrow_mut` for immutability and mutability,
respectfully.

For readability, a type alias allows us to hide those details for client use.
Our humble node:

```rust
pub type Node = Rc<RefCell<MCTNode>>;

pub struct MCTNode {
    pub game_state: GameState,
    pub children: Vec<Node>,
    pub num_rollouts: i32,
    pub unvisited_moves: Vec<Move>,
    pub win_counts: HashMap<&'static str, i32>,
    pub parent: Option<Weak<RefCell<MCTNode>>>,
    pub node_move: Option<Move>,
}
```

Yikes! Look at the parent's type. `Rc` keeps a strong reference, which means it can't be dropped.
Using `Weak` keeps a weak reference which allows it to be dropped even if the count
is more than zero. Doing this prevents memory leaks for "allowable" reference cycles.
On top of that, the value is an `Option`, since it may not be there.
In order to use a `Weak` value, it must be upgraded to an `Rc`. It's OK for a node
not to have a parent (root), so it's an `Option` too.

```rust
// whew
let parent_node = child.borrow().parent.as_ref().unwrap().upgrade().unwrap();
```

#### Back to Monte
Now that we have a tree implementation, let's execute all the rounds!
Notice the `clone` incrementing the strong `Rc` count:

```rust
for _ in 0..self.num_rounds {
    self.execute_round(root.clone());
}
```

The workhorse of the algorithm!

```rust
fn execute_round(&self, root: Node) {
    let mut node = root.clone(); // another reference increment!

    // Find the appropriate node to add a child to.
    // If the node can't add any more children, it has seen all of its moves.
    // If it's terminal, the game is over. Therefore, pick one of its children instead.
    while !node.borrow().can_add_child() && !node.borrow().is_terminal() {
        node = self.select_child(node.clone());
    }

    // Pick a random move and add it as a child. Each node corresponds to one move.
    // The node binding now becomes the new child.
    node = self.add_child_for_random_move(node.clone());

    // Simulate a game. This plays out the game from the new child node,
    // picking moves randomly for both sides (Player and Agent) until someone wins or draws.
    let winner = self.simulate_random_game(&node.borrow().game_state);

    // Record the win on this node and all of the parents up the tree.
    // RefCell allows this node to be mutated.
    node.borrow_mut().propagate_wins(winner);
}
```



#### Maturing the AI with Quarto specific rules
- Giving away a winning move
- Not taking a winning move
#### Deploying with Docker

### Final Summation
Rust is fast in prod. Things to add: difficulty setting, handle a draw
