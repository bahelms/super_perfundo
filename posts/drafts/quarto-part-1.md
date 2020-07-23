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

### Quarto (the game)
The game itself is fairly simple; it's like Tic-Tac-Toe on steroids. You must get 
four in a row to win. However, instead of having only one of two pieces to line up,
you have sixteen pieces to deal with, each one having four binary properties.
To win, you need to get four in a row that share the same property. The interesting
kicker is you pick your opponent's piece at the end of your turn. Representing 
the game and it's processes seemed like a fun coding exercise; more complicated
than Tic-Tac-Toe, but not a beast like Chess.

### Implementation mechanics
When thinking about the implementation, I began with how the board and the pieces
should be represented as data. 

### UI
  * Animating box-shadow: https://tobiasahlin.com/blog/how-to-animate-box-shadow/

### LiveView server
