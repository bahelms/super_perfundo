use super::Node;
use crate::game::{GameState, Move, Player};
use rand::Rng;

// Monte Carlo Tree Search executor
pub struct Agent {
    num_rounds: i32,
    temperature: f64,
}

impl Agent {
    pub fn new(num_rounds: i32, temperature: f64) -> Self {
        Self {
            num_rounds,
            temperature,
        }
    }

    pub fn select_move(&self, game: GameState) -> Move {
        let root = Node::new(game);

        // for i in range(self.num_rounds):
        //     node = root
        //     while (not node.can_add_child()) and (not node.is_terminal()):
        //         node = self.select_child(node)

        //     # Add a new child node into the tree.
        //     if node.can_add_child():
        //         node = node.add_random_child()

        //     # Simulate a random game from this node.
        //     winner = self.simulate_random_game(node.game_state)

        //     # Propagate scores back up the tree.
        //     while node is not None:
        //         node.record_win(winner)
        //         node = node.parent
        //
        // run rounds
        for _round in 0..self.num_rounds {
            let mut node = root.clone();
            while !node.can_add_child() && !node.is_terminal() {
                let child = &mut self
                    .select_child(&mut node)
                    .expect("A selected child was not found");
            }

            // Add a new child node into the tree.
            if child.can_add_child() {
                child.add_random_child();
            }
        }

        Move {
            position: 0,
            piece: 0,
            next_piece: 1,
        }
    }

    // Selecte node with highest UCT score.
    pub fn select_child<'a>(&self, node: &'a mut Node) -> Option<&'a mut Node> {
        let mut total_rollouts = 0.0;
        for child in &node.children {
            total_rollouts += child.num_rollouts as f64;
        }

        let mut best_score = -1.0;
        let mut best_child = None;
        for child in &mut node.children {
            let win_percentage = child.winning_fraction(node.game_state.current_player);
            let exploration_factor = (total_rollouts.log10() / child.num_rollouts as f64).sqrt();
            let uct_score = win_percentage + self.temperature * exploration_factor;
            if uct_score > best_score {
                best_score = uct_score;
                best_child = Some(child);
            }
        }

        best_child
    }

    fn simulate_random_game(&self, game: &GameState) -> Option<Player> {
        let mut current_game = game.clone();
        while !current_game.is_over() {
            let next_move = self.select_random_move(game);
            current_game = current_game.apply_move(&next_move);
        }
        current_game.winner()
    }

    fn select_random_move(&self, game: &GameState) -> Move {
        let mut rng = rand::thread_rng();
        let legal_moves = game.legal_moves();
        let index: usize = rng.gen_range(0..legal_moves.len());
        legal_moves[index].clone()
    }
}

#[cfg(test)]
mod tests {
    use super::super::Node;
    use super::*;
    use crate::game::{new_board, GameState};
    use std::collections::HashMap;

    #[test]
    fn simulate_random_game_returns_the_winning_player() {
        let mut board = new_board();
        board[1] = Some(1);
        board[2] = Some(2);
        board[3] = Some(3);
        let game = GameState::new(board, 0, "agent");
        let agent = Agent::new(5, 1.0);

        assert!(agent.simulate_random_game(&game).is_some());
    }

    #[test]
    fn select_child_works() {
        let game = GameState::new(new_board(), 0, "agent");
        let mut node = Node::new(game.clone());
        let mut child_one = Node::new(game.clone());
        let mut child_two = Node::new(game.clone());
        let mut child_three = Node::new(game);

        let mut win_counts = HashMap::new();
        win_counts.insert("agent", 3);

        child_one.num_rollouts = 5;
        child_one.win_counts = win_counts.clone();
        child_two.num_rollouts = 4;
        child_two.win_counts = win_counts.clone();
        child_three.num_rollouts = 3;
        child_three.win_counts = win_counts.clone();
        node.children = vec![child_one, child_two, child_three];

        let agent = Agent::new(5, 1.0);
        let child = agent.select_child(&mut node).unwrap();
        assert_eq!(child.num_rollouts, 3);
    }

    #[test]
    fn select_move_returns_a_move() {
        let agent = Agent::new(5, 1.0);
        let game = GameState::new(new_board(), 0, "agent");
        let next_move = agent.select_move(game);
        assert_eq!(next_move.position, 0);
        assert_eq!(next_move.piece, 0);
        assert_eq!(next_move.next_piece, 1);
    }
}
