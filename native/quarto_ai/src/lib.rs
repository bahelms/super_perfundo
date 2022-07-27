mod game;
mod mcts;

use game::{new_board, Board, GameState};
use mcts::{Agent, AGENT};
use rustler::{types::tuple::get_tuple, Term};

// rustler does not support generics currently
#[rustler::nif]
fn choose_position_and_next_piece(board: Term, active_piece: i32) -> (i32, i32) {
    let board = convert_term_to_board(board);
    let game = GameState::new(board, active_piece, AGENT);
    let agent = Agent::new(3000, 1.5);
    let selected_move = agent.select_move(game);
    (selected_move.position, selected_move.next_piece)
}

fn convert_term_to_board(board: Term) -> Board {
    let positions = get_tuple(board).expect("Error getting board tuple.");
    let mut board = new_board();
    for (i, pos) in positions.iter().enumerate() {
        // board elements are either nil or an int.
        // nil comes in as an atom here.
        if pos.is_atom() {
            board[i] = None;
        } else {
            board[i] = pos.decode().expect("Position isn't an i32");
        }
    }
    board
}

rustler::init!(
    "Elixir.SuperPerfundo.Quarto.AI",
    [choose_position_and_next_piece]
);
