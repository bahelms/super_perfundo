mod game;
mod mcts;

use game::{new_board, Board, GameState};
use mcts::Agent;
use rand::Rng;
use rustler::{types::tuple::get_tuple, Term};
use std::collections::HashSet;
use std::{thread, time};

// Monte Carlo Tree Search
//
// * create tree for given game state
// * start a round:
//   * pick a leaf node
//   * randomly place the active piece and choose the next piece
//   * add new child node with this game state
//   * execute rollout (simulate game from this node to see who wins)
//   * record the win in this node
//   * walkup all node ancestors and update their win counts
// * Set this to a certain number of rounds or amount of time
// * Once limit is reached, select the child node of the root that has the highest win rate
//
// rustler does not support generics currently
fn spike_choose_position_and_next_piece(board: Term, active_piece: i32) -> (i32, i32) {
    let board = convert_term_to_board(board);
    let game = GameState::new(board, active_piece, "agent");
    let agent = Agent::new(500, 1.4);
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

#[rustler::nif]
fn choose_position_and_next_piece(board: Term, active_piece: i32) -> (usize, i32) {
    let positions = get_tuple(board).expect("Error getting board tuple.");
    let mut empty_positions = Vec::new();
    let mut current_pieces = HashSet::from([active_piece]);

    for (idx, pos) in positions.iter().enumerate() {
        // board elements are either nil or an int.
        // nil comes in as an atom here.
        if pos.is_atom() {
            empty_positions.push(idx);
        } else {
            current_pieces.insert(pos.decode().expect("Position isn't an i32"));
        }
    }

    // choose position
    let mut rng = rand::thread_rng();
    let index: usize = rng.gen_range(0..empty_positions.len());
    let chosen_position = empty_positions[index];

    // choose next piece
    let all_pieces: HashSet<i32> = (0..16).collect();
    let remaining_pieces: Vec<&i32> = all_pieces.difference(&current_pieces).collect();
    let random_piece_idx: usize = rng.gen_range(0..remaining_pieces.len());
    let chosen_piece = *remaining_pieces[random_piece_idx];

    // sleep 1 second for random AI
    let one_second = time::Duration::from_secs(1);
    thread::sleep(one_second);

    (chosen_position, chosen_piece)
}

rustler::init!(
    "Elixir.SuperPerfundo.Quarto.AI",
    [choose_position_and_next_piece]
);
