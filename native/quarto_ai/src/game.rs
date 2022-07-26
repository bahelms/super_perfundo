use crate::mcts::{AGENT, OPPONENT};
use std::collections::HashSet;

type Piece = i32;
type Position = i32;
pub type Board = [Option<Piece>; 16];
pub type Player = &'static str;

const TWOS_COMPLIMENT_BITMASK: i32 = 0b1111;
const MATCH_POSITIONS: [[usize; 4]; 10] = [
    [0, 1, 2, 3],
    [4, 5, 6, 7],
    [8, 9, 10, 11],
    [12, 13, 14, 15],
    [0, 4, 8, 12],
    [1, 5, 9, 13],
    [2, 6, 10, 14],
    [3, 7, 11, 15],
    [0, 5, 10, 15],
    [3, 6, 9, 12],
];

#[derive(Debug, PartialEq, Clone)]
pub struct Move {
    pub position: Position,
    pub piece: Piece,
    pub next_piece: Piece,
}

#[derive(Debug, PartialEq, Clone)]
pub struct GameState {
    board: Board,
    active_piece: Piece,
    pub current_player: &'static str,
}

impl GameState {
    pub fn new(board: Board, active_piece: Piece, current_player: &'static str) -> Self {
        Self {
            board,
            active_piece,
            current_player,
        }
    }

    pub fn is_over(&self) -> bool {
        four_in_a_row(&self.board) || board_is_full(&self.board)
    }

    pub fn legal_moves(&self) -> Vec<Move> {
        let mut legal_moves = Vec::new();
        let mut empty_positions = Vec::new();
        let mut played_pieces = HashSet::from([self.active_piece]);

        for (idx, pos) in self.board.iter().enumerate() {
            match pos {
                Some(piece) => {
                    played_pieces.insert(*piece);
                }
                None => empty_positions.push(idx as i32),
            }
        }

        let all_pieces: HashSet<i32> = (0..16).collect(); // optimize
        let remaining_pieces: Vec<i32> = all_pieces.difference(&played_pieces).copied().collect();

        for position in empty_positions {
            for &remaining_piece in &remaining_pieces {
                legal_moves.push(Move {
                    position,
                    piece: self.active_piece,
                    next_piece: remaining_piece,
                });
            }
        }
        legal_moves
    }

    pub fn apply_move(&self, the_move: &Move) -> Self {
        let mut next_board = self.board.clone();
        next_board[the_move.position as usize] = Some(the_move.piece);
        GameState::new(next_board, the_move.next_piece, self.next_player())
    }

    fn next_player(&self) -> Player {
        match self.current_player {
            AGENT => OPPONENT,
            OPPONENT => AGENT,
            &_ => panic!("Current player is unsupported {}", self.current_player),
        }
    }

    pub fn winner(&self) -> Option<Player> {
        if !self.is_over() {
            return None;
        }
        if four_in_a_row(&self.board) {
            return Some(self.current_player);
        }
        None
    }
}

pub fn new_board() -> Board {
    [
        None, None, None, None, None, None, None, None, None, None, None, None, None, None, None,
        None,
    ]
}

fn board_is_full(board: &Board) -> bool {
    for piece in board {
        match piece {
            None => return false,
            _ => (),
        }
    }
    true
}

fn four_in_a_row(board: &Board) -> bool {
    for positions in MATCH_POSITIONS {
        let mut pieces = Vec::new();
        for pos in positions {
            pieces.push(board[pos]);
        }
        let left = match_pieces(pieces[0], pieces[1]);
        let right = match_pieces(pieces[2], pieces[3]);
        if any_matches(left, right) {
            let match_zero_two = match_pieces(pieces[0], pieces[2]);
            if any_matches(match_zero_two, Some(left.unwrap() & right.unwrap())) {
                return true;
            }
        }
    }
    false
}

fn match_pieces(left: Option<Piece>, right: Option<Piece>) -> Option<i32> {
    if left.is_none() {
        return None;
    }
    if right.is_none() {
        return None;
    }
    Some((!(left.unwrap() ^ right.unwrap())) & TWOS_COMPLIMENT_BITMASK)
}

fn any_matches(left: Option<Piece>, right: Option<Piece>) -> bool {
    if left.is_none() {
        return false;
    }
    if right.is_none() {
        return false;
    }
    left.unwrap() & right.unwrap() > 0
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::mcts::{AGENT, OPPONENT};

    fn draw_board() -> Board {
        [
            Some(7),  // 0111
            Some(8),  // 1000
            Some(5),  // 0101
            Some(10), // 1010
            Some(12), // 1100
            Some(3),  // 0011
            Some(14), // 1110
            Some(1),  // 0001
            Some(15), // 1111
            Some(13), // 1101
            Some(9),  // 1001
            Some(6),  // 0110
            Some(2),  // 0010
            Some(11), // 1011
            Some(4),  // 0100
            Some(0),  // 0001
        ]
    }

    #[test]
    fn game_winner_is_none_when_neither_side_has_won() {
        let state = GameState::new(draw_board(), 0, OPPONENT);
        assert_eq!(state.winner(), None);
    }

    #[test]
    fn game_winner_is_current_player_with_four_in_a_row() {
        let board = [Some(0); 16];
        let state = GameState::new(board, 0, OPPONENT);
        assert_eq!(state.winner().unwrap(), OPPONENT);
    }

    #[test]
    fn game_winner_returns_none_when_game_is_not_over() {
        let state = GameState::new(new_board(), 0, OPPONENT);
        assert_eq!(state.winner(), None);
    }

    #[test]
    fn apply_move_returns_updated_game_state() {
        let state = GameState::new(new_board(), 0, OPPONENT);
        let new_move = Move {
            position: 1,
            piece: 2,
            next_piece: 8,
        };
        let new_state = state.apply_move(&new_move);
        assert_eq!(new_state.board[1].unwrap(), 2);
        assert_eq!(new_state.active_piece, 8);
        assert_eq!(new_state.current_player, AGENT);
        assert_ne!(new_state.board, state.board);
    }

    #[test]
    fn is_over_is_true_when_the_board_is_full() {
        let mut board = new_board();
        for i in 0..16 {
            board[i] = Some(i as Piece);
        }
        let game = GameState::new(board, 0, OPPONENT);
        assert_eq!(game.is_over(), true);
    }

    #[test]
    fn is_over_is_true_when_four_in_a_row_exists() {
        let mut board = new_board();
        board[0] = Some(0);
        board[1] = Some(2);
        board[2] = Some(4);
        board[3] = Some(8);
        let game = GameState::new(board, 15, OPPONENT);
        assert_eq!(game.is_over(), true);
    }

    #[test]
    fn is_over_is_false_when_the_board_is_empty() {
        let game = GameState::new(new_board(), 0, AGENT);
        assert_eq!(game.is_over(), false);
    }

    #[test]
    fn legal_moves_returns_correct_move_data() {
        let board = [
            Some(0),
            Some(1),
            Some(2),
            Some(3),
            Some(4),
            Some(5),
            Some(6),
            Some(7),
            Some(8),
            Some(9),
            Some(10),
            Some(11),
            Some(12),
            None,
            None,
            None,
        ];
        let state = GameState::new(board, 15, AGENT);
        let legal_moves = state.legal_moves();
        assert_eq!(legal_moves.len(), 6);
    }

    #[test]
    fn legal_moves_returns_a_vector_of_moves() {
        let state = GameState::new(new_board(), 0, AGENT);
        let legal_moves = state.legal_moves();
        assert_eq!(legal_moves.len(), 16 * 15);
    }

    #[test]
    fn four_in_a_row_matches_four_dark_pieces() {
        let mut board = new_board();
        board[0] = Some(1);
        board[1] = Some(3);
        board[2] = Some(5);
        board[3] = Some(9);
        assert_eq!(four_in_a_row(&board), true);
    }

    #[test]
    fn four_in_a_row_matches_four_solid_pieces() {
        let mut board = new_board();
        board[0] = Some(0);
        board[1] = Some(1);
        board[2] = Some(4);
        board[3] = Some(8);
        assert_eq!(four_in_a_row(&board), true);
    }

    #[test]
    fn four_in_a_row_matches_four_hollow_pieces() {
        let mut board = new_board();
        board[0] = Some(2);
        board[1] = Some(3);
        board[2] = Some(6);
        board[3] = Some(10);
        assert_eq!(four_in_a_row(&board), true);
    }

    #[test]
    fn four_in_a_row_matches_four_short_pieces() {
        let mut board = new_board();
        board[0] = Some(0);
        board[1] = Some(1);
        board[2] = Some(2);
        board[3] = Some(8);
        assert_eq!(four_in_a_row(&board), true);
    }

    #[test]
    fn four_in_a_row_matches_four_tall_pieces() {
        let mut board = new_board();
        board[0] = Some(4);
        board[1] = Some(5);
        board[2] = Some(6);
        board[3] = Some(12);
        assert_eq!(four_in_a_row(&board), true);
    }

    #[test]
    fn four_in_a_row_matches_four_cube_pieces() {
        let mut board = new_board();
        board[0] = Some(0);
        board[1] = Some(1);
        board[2] = Some(2);
        board[3] = Some(4);
        assert_eq!(four_in_a_row(&board), true);
    }

    #[test]
    fn four_in_a_row_matches_four_cylinder_pieces() {
        let mut board = new_board();
        board[0] = Some(8);
        board[1] = Some(9);
        board[2] = Some(10);
        board[3] = Some(12);
        assert_eq!(four_in_a_row(&board), true);
    }

    #[test]
    fn four_in_a_row_handles_false_positives() {
        let mut board = new_board();
        board[0] = Some(15);
        board[1] = Some(10);
        board[2] = Some(9);
        board[3] = Some(4);
        assert_eq!(four_in_a_row(&board), false);
    }

    #[test]
    fn four_in_a_row_returns_false_when_four_pieces_do_not_match() {
        let board = new_board();
        assert_eq!(four_in_a_row(&board), false)
    }

    #[test]
    fn four_in_a_row_returns_false_for_a_draw_board() {
        assert_eq!(four_in_a_row(&draw_board()), false);
    }
}
