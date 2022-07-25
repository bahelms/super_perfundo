# NIF for Elixir.QuartoAI
Quarto has 240 moves with an empty board, after first piece selection. Chess - 20, Go - 361

## Todo
- Add a step to see if the next move is a win. A child is never selected.
- Refactor
    - NodeBuilder to include parent:
        ```
        let parent: Node = NodeBuilder::new(game).build();
        let child: Node = NodeBuilder::new(game).with_parent(&parent).build();
        ```
    - GameState.current_player to be an enum:
        - `Player::Agent` and `Player::Opponent`
