# NIF for Elixir.QuartoAI
Quarto has 240 moves with an empty board, after first piece selection. Chess - 20, Go - 361

## Todo
- Add a step to see if the next move is a win. A child is never selected.
- Refactor
    - Add heuristic to prevent handing over winning moves.
    - GameState.current_player to be an enum:
        - `Player::Agent` and `Player::Opponent`
