==title==
Quarto, pt. 1: Core Functionality

==tags==
elixir, phoenix, live-view, games, quarto

==description==
Building a Quarto game with Phoenix LiveView. Game mechanics, dynamic UI, and 
how LiveView ties it all together.

==body==
I do handtool woodworking as a hobby, and I first heard of Quarto while I was browsing
videos for board game projects. It seemed like Tic-Tac-Toe for adults, and I thought
it would make for a fun garage project. Immediately after that thought, I had another
one. It would also be cool to make a web version!

This will be a duology of posts detailing how I went about implementing Quarto
as a web app. This first post covers the majority of how the app functions. In a
future post, I'll go over writing an AI for the user to play against.

### The Game of Quarto 
The game itself is fairly simple; it's like Tic-Tac-Toe on steroids. You must get 
four in a row to win. However, instead of having only one of two pieces to line up,
you have sixteen pieces to deal with, each one having four binary properties.
To win, you need to get four in a row that share the same property. The interesting
kicker is you pick your opponent's piece at the end of your turn. Representing 
the game and it's processes seemed like a fun coding exercise; more complicated
than Tic-Tac-Toe, but not a beast like Chess.

### Implementation Mechanics
#### Pieces
When thinking about the implementation, I began with how the board and the pieces
should be represented as data. A piece has four properties with each property being one of
two possibilities. Four binary properties for a total of sixteen combinations? 
That's a [nibble!](https://en.wikipedia.org/wiki/Nibble){:target="x"} Therefore, 
the most efficient way to model the pieces is to use the integers 0-15. After 
deciding that, I picked an arbitrary mapping of bit to property:

    @property_map %{
      shape: %{"0" => "cube", "1" => "cylinder"},
      size: %{"0" => "short", "1" => "tall"},
      fill: %{"0" => "solid", "1" => "hollow"},
      color: %{"0" => "light", "1" => "dark"}
    }

To enforce the order of the bits (again arbitrarily chosen), I convert
the integer to a string of base 2 digits and extract the values in a pattern match.
This tells me that number seven (`0101`) represents a tall, dark, solid cube. I
think that's pretty cool:

    <<shape, size, fill, color>> = 
      7
      |> Integer.to_string(2)
      |> String.pad_leading(4, "0")


#### Board
Now that I know what the pieces look like, how do I place them? The board is a 
4x4 grid, but that doesn't matter with the data representation. What matters is 
that it contains sixteen positions that can be chosen at random. This means I need
a collection that is hardcoded to a capacity of 16 and provides efficient random 
access. In Elixir, that structure is the tuple. Here's what a random board looks like:

    {nil, 0, nil, nil, nil, 13, nil, nil, 2, nil, nil, nil, nil, 10, nil, nil}

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

A "gotcha" I found when implementing this is that negating the number converts it into a negative number.
Getting the two's complement (`& 1111`) is necessary to find the true number I'm looking for.

### User Interface
With the core game logic done, I now had to figure out how to render the game 
so that it would look good (most importantly), and actually be playable.

* Animating box-shadow: https://tobiasahlin.com/blog/how-to-animate-box-shadow/

### LiveView Server
