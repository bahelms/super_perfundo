use std::collections::HashSet;

type Piece = i32;
type Position = i32;
pub type Board = [Option<Piece>; 16];

#[derive(Debug, PartialEq)]
pub struct GameState {
    board: Board,
    active_piece: Piece,
}

impl GameState {
    pub fn new(board: Board, active_piece: Piece) -> Self {
        Self {
            board,
            active_piece,
        }
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
            for &next_piece in &remaining_pieces {
                legal_moves.push(Move {
                    position,
                    next_piece,
                    piece: self.active_piece,
                })
            }
        }
        legal_moves
    }
}

#[derive(Debug, PartialEq)]
pub struct Move {
    position: Position,
    piece: Piece,
    next_piece: Piece,
}

pub fn new_board() -> Board {
    [
        None, None, None, None, None, None, None, None, None, None, None, None, None, None, None,
        None,
    ]
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn legal_moves_returns_a_vector_of_moves() {
        let state = GameState::new(new_board(), 0);
        let legal_moves = state.legal_moves();
        assert_eq!(legal_moves.len(), 16 * 15);
    }
}
