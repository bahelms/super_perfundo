==title==
Quarto, pt. 1: Core Functionality

==tags==
elixir, phoenix, live-view, games, quarto, css

==description==
Building a Quarto game with Phoenix LiveView. Game mechanics, dynamic UI, and 
how LiveView ties it all together.

==body==
I do handtool woodworking as a hobby, and I first heard of Quarto while I was browsing
YouTube videos for board game projects. It seemed like Tic-Tac-Toe for adults, and I thought,
besides being a fun garage project, it would also be an interesting programming 
exercise.

This will be a duology of posts detailing how I went about implementing Quarto
as a web app. This first post covers the majority of how the app functions. In a
future post, I'll go over writing a useful AI for the user to play against.

If you want to play, click [here](/quarto) or that button in the menu up there ^.
I focused only on getting this to render properly for desktop browsers. It is most definitely not
mobile-friendly currently, so don't try to play it on your phone.

### The Game of Quarto 
The game itself is fairly simple; it's like Tic-Tac-Toe on steroids. You must get 
four in a row to win. However, instead of having only one of two types of pieces to line up,
you have sixteen to deal with, each one having four binary properties.
To win, you need to get four in a row that have at least one property in common. The 
kicker is you pick your opponent's piece at the end of your turn. Representing 
the game and it's processes seemed like an enjoyable effort; more complicated
than Tic-Tac-Toe, but not a non-trivial beast like Chess.

### Implementation Mechanics
#### Pieces
When thinking about the implementation, I began with how the board and the pieces
should be represented as data. A piece has four properties with each property having
two possibilities. Four binary properties for a total of sixteen combinations? 
That's a [nibble!](https://en.wikipedia.org/wiki/Nibble){:target="x"} Therefore, 
the most efficient way to model the pieces is to use the integers 0-15. After 
deciding that, I picked an arbitrary mapping of bit to property:

```elixir
@property_map %{
  shape: %{"0" => "cube", "1" => "cylinder"},
  size: %{"0" => "short", "1" => "tall"},
  fill: %{"0" => "solid", "1" => "hollow"},
  color: %{"0" => "light", "1" => "dark"}
}
```

To enforce the order of the bits (again arbitrarily chosen), I convert
the integer to a string of base 2 digits and extract the values in a pattern match.
This tells me that number seven (`0101`) represents a tall, dark, solid cube. I
think that's pretty cool:

```elixir
<<shape, size, fill, color>> =
  7
  |> Integer.to_string(2)
  |> String.pad_leading(4, "0")
```

#### Board
Now that I know what the pieces look like, how do I place them? The board is a 
4x4 grid, but that doesn't matter with the data representation. What matters is 
that it contains sixteen positions that can be chosen at random. This means I need
a collection that is hardcoded to a capacity of 16 and provides efficient random 
access. In Elixir, that structure is the tuple. Here's what a random board looks like:

```elixir
{nil, 0, nil, nil, nil, 13, nil, nil, 2, nil, nil, nil, nil, 10, nil, nil}
```

This is the source of truth of played pieces. In order to display the remaining 
pieces from which a player must select, I convert the board into a set
and take its difference from the set of all pieces.

#### Check For A Winning State
Figuring out the data was fairly straightforward. Checking if the board has four
pieces in a row that share one of four properties is a little more involved. Since
the pieces consist of bits, I figured bitwise operations would be the best way to 
determine when four pieces had the same value in the same bit position. This type 
of stuff is my favorite part of computer science: data and algorithms. 

It took some time thinking through the combinations of operations necessary to find
this information. I went through several rounds of drawing board sessions due to 
one algorithm working in one state but not another (which I would find while playing
the game myself). One problem is that bitwise ops consider
0 to be a non-value. In the game logic, 0 was just as important as 1, so it couldn't
be abandoned during the pipeline of operations. Another problem is bitwise ops only
work with two operands, but the game needs to compare four at once. The following
psuedocode describes the correct combination of operations:

    # Given: 0000, 0100, 0010, 0011
    round1 = (~(0000 ^ 0100) & 1111) & (~(0010 ^ 0011) & 1111) # 1010
    true_match = (~(0000 ^ 0010) & 1111) & round1 # 1000

The left number pair and the right number pair are XORed, negated, then ANDed,
and those resulting values then ANDed together.
If `round1` is over 0, there is a match; however, there may also be false positives
at this point, since four values are first merged to two then to one. Therefore, we must also
compare the result of the first and third numbers with `round1` to get the true
match of the single property shared by all numbers in this example. 

To see if four in a row exists on the board, this check must run for every direction 
(vertical, horizontal, diagonal). The shortened Elixir for doing this:

```elixir
import Bitwise

@match_positions [
  [0, 1, 2, 3],
  [4, 5, 6, 7],
  [8, 9, 10, 11],
  [12, 13, 14, 15],
  [0, 4, 8, 12],
  [1, 5, 9, 13],
  [2, 6, 10, 14],
  [3, 7, 11, 15],
  [0, 5, 10, 15],
  [3, 6, 9, 12]
]

def four_in_a_row?(board) do
  Enum.find(@match_positions, fn positions ->
    [one, two, three, four] = Enum.map(positions, &elem(board, &1))
    left = match_pieces(one, two)
    right = match_pieces(three, four)

    if any_matches?(left, right) do
      match_pieces(one, three)
      |> any_matches?(band(left, right))
    end
  end)
end

defp match_pieces(left, right) do
  left
  |> bxor(right)
  |> bnot()
  |> band(@twos_compliment_bitmask)
end

defp any_matches?(left, right), do: band(left, right) > 0
```

A "gotcha" I found when implementing this is that negating the number converts it into a negative number.
Getting the two's complement (`& 1111`) is necessary to find the true number I'm looking for.

### User Interface
With the core game logic done, I now had to figure out how to render the game 
so that it would look good (most importantly), and actually be playable.
I didn't want to use a bunch of static images for the pieces and empty board.
I wanted it to be dynamically rendered. I started out with SVGs, but they involved
a lot of long decimals in order to get the 3D look, so
I abandoned them and settled on drawing everything with pure CSS.

To display a piece, the integer is converted to a struct and given to a stateless 
Live Component. The properties of the piece determine which CSS classes to apply.
It was fairly straigtforward to make 3D cubes and cylinders with `transform`.
For some added panache, when a piece is placed on the board, it has a nice intro animation.

```elixir
# e.g. "1010"
defp nibble_to_piece(<<shape, size, fill, color>>) do
  %Piece{
    shape: @property_map.shape[<<shape>>],
    size: @property_map.size[<<size>>],
    fill: @property_map.fill[<<fill>>],
    color: @property_map.color[<<color>>]
  }
end

def render(assigns) do
  ~L"""
  <div class="piece">
    <%= if @piece.shape == "cube" do %>
      <div class="cube">
        <div class="side front <%= @piece.size %> <%= @piece.color %>"></div>
        <div class="side back <%= @piece.size %> <%= @piece.color %>"></div>
        <div class="side top <%= @piece.size %> <%= @piece.color %>"></div>
        <div class="side bottom <%= @piece.size %> <%= @piece.color %>"></div>
        <div class="side left <%= @piece.size %> <%= @piece.color %>"></div>
        <div class="side right <%= @piece.size %> <%= @piece.color %>"></div>
        <%= if @piece.fill == "hollow" do %>
          <div class="hollow <%= @piece.size %>"></div>
        <% end %>
      </div>
    <% else %>
      <div class="cylinder <%= @piece.size %>">
        <div class="bottom <%= @piece.size %> <%= @piece.color %>"></div>
        <div class="middle <%= @piece.size %> <%= @piece.color %>"></div>
        <div class="top <%= @piece.color %>"></div>
        <%= if @piece.fill == "hollow" do %>
          <div class="hollow"></div>
        <% end %>
      </div>
    <% end %>
  </div>
  """
end
```

The board is just a flexbox of divs styled as circles. The only other thing of note
is the Remaining Pieces container. It originally began as a modal for selecting
the piece your opponent would play. However, I found that not being able to see 
the board while making a tactical decision was less than ideal. It also helped to be
able to see the remaining pieces at any time (not just when selecting the next one).
Therefore, I changed the modal to be an always present div to the side of the board
that shows the pool of pieces remaining. When it's time for the user to pick the next
piece, the container gets emphasis by animating its box shadow and darkening everything
else on the screen. Pretty cool.

### LiveView Server
Now for the technology I was most excited about using: 
[Phoenix's LiveView](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.html){:target="x"}. 
It allows you to add super performant client-side behavior without touching any client-side
code (apart from HTML). That's right! This project didn't require a single line
of JavaScript on my part! Everything this game needs is all Elixir on the server-side.

When the game starts, it's rendered with an empty board and no active piece or 
player. A "coin" is flipped to determine if the AI or the user goes first. This 
is a simple random choice from a list of two elements: `Enum.random([:ai, :user])`.
Let's say the user plays first. With no active piece, they can only perform the second
action, choosing the piece for the opponent to play by clicking on one of the remaining
pieces.

```elixir
<div class="remaining-pieces">
  <%= for piece <- Board.remaining_pieces(@board, @active_piece) do %>
    <div phx-click="piece_chosen" phx-value-piece="<%= piece %>">
      <%= live_component(@socket, PieceComponent, piece: piece) %>
    </div>
  <% end %>
</div>
```

This sends the `piece_chosen` event back to the server with the value of the piece,
where the game logic is executed.

```elixir
def handle_event("piece_chosen", %{"piece" => piece}, socket) do
  with nil <- socket.assigns.winning_state,
        nil <- socket.assigns.active_piece do
    send(self(), :ai_start)

    {:noreply,
      assign(socket,
        active_piece: String.to_integer(piece),
        active_player: :ai
      )}
  else
    _ ->
      {:noreply, socket}
  end
end
```

As long is there is no already active piece and no player has won yet 
(to prevent undesirable game behavior from occuring), the AI's
turn begins and the state is updated accordingly. This will rerender only the active player and 
active piece sections on the client and display a spinner while the asynchronous AI task 
finishes making its decisions.

```elixir
def handle_info(:ai_start, socket = %{assigns: %{board: board, active_piece: piece}}) do
  {position, next_piece} = AI.choose_position_and_next_piece(board, piece)
  board = Board.set_piece(board, piece, position)
  winning_state = Board.four_in_a_row?(board)
  ...
end
```

Once the AI has chosen the position to play and the piece to 
pass to the user, the board is set, checked for a winning state, and then the 
socket updated, which in turn rerenders only the relevant parts of the client. 
The AI implementation used here is essentially a placeholder for the next iteration.
Its decisions are entirely random and thus very easy to beat.

```elixir
@doc """
Easiest AI ever! This picks a random position for the given piece and a random
piece to use next.
"""
def choose_position_and_next_piece(board, active_piece) do
  position =
    board
    |> open_positions()
    |> Enum.take_random(1)
    |> List.first()

  next_piece =
    board
    |> Board.remaining_pieces(active_piece)
    |> Enum.take_random(1)
    |> List.first()

  :timer.sleep(1000)
  {position, next_piece}
end

defp open_positions(board) do
  for index <- 0..15, !elem(board, index), do: index
end
```

This entire workflow of code (event -> server -> AI -> rerender) happens so
fast, I needed to put in a one second delay to even see the "AI thinking" spinner.
It seemed jarring for the AI's moves to be rendered so immediately. Anyhow, this
module will most likely turn into Rust NIFs when I implement a true AI. Being able to set 
deep game tree search levels will no doubt eliminate the need for a `sleep`!

### Final Summation
LiveView is a brilliant technology. It can be sprinkled throughout a web app easily,
and allows developers to avoid having to deal with a separate frontend. I certainly
would rather be playing with the BEAM over JavaScript any day. I highly recommend
you give it a spin if you haven't already. 

In the [next post](/articles/quarto-part-2.1), I'll go over writing a true AI for playing Quarto. It'll be an
excuse to use Rust, which I've been wanting to do lately. I think this will be a
good use case for it since speed and large computations will be necessary to make
a strong AI and still maintain a playable game. I've also been considering adding
an option to play other humans in a future iteration. Perhaps adding a chatbox below
the game board for trash talking and the like. All while avoiding a single drop 
of JS (hopefully). Cheers!
