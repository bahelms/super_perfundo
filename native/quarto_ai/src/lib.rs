use rand::Rng;
use rustler::{types::tuple::get_tuple, Term};
use std::collections::HashSet;
use std::{thread, time};

// rustler does not support generics currently
#[rustler::nif]
fn choose_position_and_next_piece(board: Term, active_piece: i32) -> (usize, usize) {
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
    let chosen_piece = *remaining_pieces[random_piece_idx] as usize;

    // sleep 1 second for random AI
    let one_second = time::Duration::from_secs(1);
    thread::sleep(one_second);

    (chosen_position, chosen_piece)
}

rustler::init!(
    "Elixir.SuperPerfundo.Quarto.AI",
    [choose_position_and_next_piece]
);
