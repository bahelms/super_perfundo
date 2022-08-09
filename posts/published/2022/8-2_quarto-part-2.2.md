==title==
Quarto, pt. 2.2: AI - Behind The Curtain

==tags==
elixir, rust, ai, games, quarto, algrithms

==description==
How to actually write this silly robot. It's fun. I promise!

==image==
monte-carlo.png

==body==
We've made it! I'm not gonna lie, this part was tough. But, Oh! The things
one can accomplish with grit, determination, perseverance, tenacity, all that.
If you've stumbled on this post and haven't read the precursors, you're not going
to have any idea what I'm talking about. Start here: [Part 1](/articles/quarto-part-1).

The full code for this AI can be found [here](https://github.com/bahelms/super_perfundo/tree/master/native/quarto_ai){:target="x"}.

### Step 1: The Algorithm - Monte Carlo Tree Search
Because machine learning is fascinating and games are fun, I started reading
[Deep Learning and the Game of Go](https://www.manning.com/books/deep-learning-and-the-game-of-go){:target="x"}
(remember when a computer first beat the Go world champion? It was paradigm shifting).
I didn't realize it at the time, but the first part of the book would enlighten me
on how to build an AI for Quarto. It goes over traditional board game engine techniques like minimax,
alpha beta pruning, and Monte Carlo tree search. I thought using deep learning for Quarto right out the gate
would be overkill, so the conventional route seemed the best place to start.
The problem with minimax/alpha-beta pruning is that they depend on a heuristic function
that can examine the state of the game and concretely tell you which side is doing better.
For Quarto, and even tic-tac-toe for that matter, I had no idea how to suss out an advantage
just by looking at the board and remaining pieces (apart from next-move-wins).
However, Monte Carlo tree search was designed not to need such a heuristic.
We can solve the problem by avoiding it. Perfect!

Similar to reinforcement learning, MCTS plays lots of games in order to find the best move.
It takes a given game state and plays out
as many moves as possible within a given time limit. These are called rollouts. The moves are randomly selected
each turn, and the branch that ends up with the highest win rate is chosen. It would
take too long to see every possibility, so processing is constrained by the number of iterations
or a length of time. Therefore, even with the odds in your favor, you still might lose the bet.
This is why it was named after Monte Carlo, a place world famous for gambling.

Here's my tl;dr that guided me through the coding process:

    - create tree (root node) for given game state
    - start a round:
        - pick a leaf node
        - randomly place the active piece and choose the next piece (a Quarto move)
        - add new child node with this game state
        - execute rollout (simulate game from this node to see who wins)
        - record the win in this node
        - walkup all node ancestors and update their win counts
    - Set this to a certain number of rounds
        - Once limit is reached, select the child node of the root that has the highest win rate

### Step B: The Codes

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
the best move for the AI (represented as `AGENT`). Alright! We're done. I hope you enjoyed...oh,
you want to see what the agent does? Fine.

```rust
pub struct Agent {
    num_rounds: i32,
    temperature: f64, // used in child selection
}
```

One thing it takes is the number of game simulation rounds. This is our time constraint.
More rounds increase the accuracy, but also the time the user spends watching a
spinny thing. Inside `select_move`:

```rust
pub fn select_move(&self, game: GameState) -> Move {
    let root = NodeBuilder::new(game).build();
```

And there we have the fundamental headache that must be dealt with: what is a node? what is a tree? who am I?

#### Rc&lt;RefCell> Hell - writing a cyclical tree in Rust
Rust by default does not like it when you create objects that reference each other.
In our tree, a node needs to point to an array of child nodes. It's totally fine for the parent
to own the children (until they're 18). The problem is when the child nodes need to
reference their parent (children can't also own their parents, but grandparents are
expected to borrow the children! Ok I'm done). If the child has a reference to the
parent but itself is also owned by the parent, neither can ever be dropped!

Several painful iterations were spent on how to get past this paradox, and I settled
on using `Rc`, `Weak`, and `RefCell`. It definitely adds mental overhead, and it's basically
a way to sneak around Rust's natural ownership/borrowing mechanics. `Rc` wraps a value and
keeps track of how many references point to it: `Rc::new(node)`. You can access its wrapped data
as usual, but it's immutable. Calling `clone` on it creates a new reference and increases
the count. It's only dropped once the count is zero. We're going to be adding children
to a node's array, so it will need to be mutable. That's were `RefCell` comes in.
It allows an `Rc`'s value to be mutable. `Rc::new(RefCell::new(node))`.
Now to access that value we use `borrow` (immutable) and `borrow_mut` (mutable).

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

Yikes! Look at the parent's type. `Rc` keeps a strong reference, which means its value can't be dropped.
`Weak` keeps a reference that can be dropped at any time, regardless of the count.
Because of this, the value is an `Option`, since it may not be there.
Doing this prevents memory leaks for "allowable" reference cycles through `Rc`
(here be dragons outside of natural borrowing).
In order to use a `Weak` value, it must be upgraded to an `Rc`. In addition, our node
may not even have a parent, so it's an `Option`, too.

```rust
// borrow to get the MCTNode, get its parent as an Option ref, unwrap the Option,
// upgrade the Weak ref, then unwrap that Option. whew
let parent_node = child.borrow().parent.as_ref().unwrap().upgrade().unwrap();
```

#### Back to Monte
Now that we have a non-leaky working tree, let's execute all the rounds!
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
    // If it's terminal, its game is over.
    // Therefore, use one of its children instead of it.
    while !node.borrow().can_add_child() && !node.borrow().is_terminal() {
        node = self.select_child(node.clone());
    }

    // Pick a random move and add it as a child. Each node corresponds to one move.
    // This node binding now becomes the new child.
    node = self.add_child_for_random_move(node.clone());

    // Simulate a game. This plays out the game from the new child node,
    // picking moves randomly for both sides (Player and Agent) until someone wins or draws.
    let winner = self.simulate_random_game(&node.borrow().game_state);

    // Record the win on this node and all of the parents up the tree.
    // win_counts is a hash: ("player" -> i32, "agent" -> i32)
    // RefCell allows this node to be mutated.
    node.borrow_mut().propagate_wins(winner);
}
```

Let's peek at a couple of these methods. I think the code is mostly self explanatory.

```rust
fn add_child_for_random_move(&self, node: Node) -> Node {
    // nodes keep track of which moves have been seen
    let next_move = node.borrow_mut().select_next_random_move();
    let new_game_state = node.borrow().game_state.apply_move(&next_move);
    // using the builder pattern to hide that node complexity we discussed
    let child = NodeBuilder::new(new_game_state)
        .node_move(next_move)
        .parent(Rc::downgrade(&node)) // turning the Rc into a Weak
        .build();
    node.borrow_mut().children.push(child); // move ownership to parent node
    node.borrow().children.last().unwrap().clone() // return a child reference
}

fn simulate_random_game(&self, game: &GameState) -> Option<Player> {
    let mut current_game = game.clone(); // this is an actual value copy
    while !current_game.is_over() {
        let next_move = self.select_random_move(game);
        current_game = current_game.apply_move(&next_move);
    }
    current_game.winner()
}

fn select_random_move(&self, game: &GameState) -> Move {
    let legal_moves = game.legal_moves();
    let mut rng = rand::thread_rng();
    // get a random index for the array of legal moves
    let index: usize = rng.gen_range(0..legal_moves.len());
    legal_moves[index].clone() // actual copy. Like I said, mental overhead.
}

// GameState
pub fn apply_move(&self, the_move: &Move) -> Self {
    let mut next_board = self.board.clone(); // brand new board
    // put the piece in position
    next_board[the_move.position as usize] = Some(the_move.piece);
    // new game state for next piece and player
    GameState::new(next_board, the_move.next_piece, self.next_player())
}
```

There is a lot more code that would make this post pretty long if we went over it all here.
Feel free to spelunk for yourself [at the repo](https://github.com/bahelms/super_perfundo/tree/master/native/quarto_ai){:target="x"}.
After all the rounds are over and our tree has been populated with win counts,
we iterate over all of the root's children and pick the move that had the highest
win rate for the AI. Fin.

#### Maturing the AI with Quarto specific rules
After playing the game for awhile, I noticed that the AI would hand me winning moves
and totally miss the winning moves I gave it. This is because not every move may be visited
in Monte. The branch may contain a losing move for the AI that it didn't see and
end up with a higher win percentage overall. These "next move wins" situations could be
eliminated or capitalized on with some specific logic.

Before we even begin executing rounds for a game, we can check to see if the move
given to the AI is winning.

```rust
// If agent is given a winning move, take it!
if let Some(winning_move) = root.borrow().game_state.winning_move() {
    return winning_move
}
```

On the flip side, when we're going through the children to find the best move,
if it is losing for the AI, skip it.

```rust
for child in &node.borrow().children {
    // this applies the move to the game state and checks if the new game is over.
    if self.is_losing_move(child.clone(), node.clone()) {
        continue;
    }
```

#### Deploying with Docker
One last thing to note is the unforeseen difficulty in deploying the app.
[Read here about how it's done](/articles/super-perfundo).
The problem was that now Rust needed to be installed in the Docker image. Because
of the base image it uses, this took some trial and error.

    # builder container
        FROM bitwalker/alpine-elixir-phoenix:1.11.4 as builder

        # install Rust
        RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        ENV PATH $HOME.cargo/bin:$PATH
        ENV RUSTFLAGS="-C target-feature=-crt-static"

    # then in the runner container
        FROM bitwalker/alpine-elixir:1.11.4

        # install runtime deps for Rust
        RUN apk update --no-cache && \
            apk add --no-cache \
            libgcc

### Final Summation
It took some blood and tears to get this thing live, but boy it was satisfying when
it started beating me. You have to slow down and think or you will lose. It's hardcoded
to 3000 rounds as of this writing, which provides about two or three seconds of latency in dev
but it's blazing fast in prod. I feel like this puts it to about a medium difficulty. Something
I'd like to add is an option for the player to choose a difficulty setting. That will
control the number of rounds to spend evaluating moves. Also, I need to fix the UI
to handle draws (they happen!). I was happy to have found Monte Carlo tree search.
It made it easier to find winning moves without being dependent on game specific
heuristics. Thanks go to
[Deep Learning and the Game of Go](https://www.manning.com/books/deep-learning-and-the-game-of-go){:target="x"}.
It's a great book, so check it out. Enough talk. [Go and play!](/quarto) <sub>(just not on mobile :D)</sub>
