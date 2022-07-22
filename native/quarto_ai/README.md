# NIF for Elixir.QuartoAI

## To build the NIF module:

- Your NIF will now build along with your project.

## To load the NIF:

```elixir
defmodule QuartoAI do
    use Rustler, otp_app: :super_perfundo, crate: "quarto_ai"

    # When your NIF is loaded, it will override this function.
    def add(_a, _b), do: :erlang.nif_error(:nif_not_loaded)
end
```

## Examples

[This](https://github.com/hansihe/NifIo) is a complete example of a NIF written in Rust.

## Todo
- Refactor
    - NodeBuilder to include parent:
        ```
        let parent: Node = NodeBuilder::new(game).build();
        let child: Node = NodeBuilder::new(game).with_parent(&parent).build();
        ```
    - GameState.current_player to be an enum:
        - `Player::Agent` and `Player::Opponent`
