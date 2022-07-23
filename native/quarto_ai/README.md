# NIF for Elixir.QuartoAI
Quarto has 3,840 moves with an empty board.

## Todo
- Refactor
    - NodeBuilder to include parent:
        ```
        let parent: Node = NodeBuilder::new(game).build();
        let child: Node = NodeBuilder::new(game).with_parent(&parent).build();
        ```
    - GameState.current_player to be an enum:
        - `Player::Agent` and `Player::Opponent`
