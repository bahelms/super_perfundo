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

### Step B: The Codes

#### Translating Python to Rust
#### `Rc<RefCell>` Hell - writing a cyclical tree in Rust
#### Maturing the AI with Quarto specific rules
- Giving away a winning move
- Not taking a winning move

### Final Summation
Rust is fast in prod
