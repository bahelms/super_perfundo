use super::Node;
use crate::game::{GameState, Move};

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
        for round in 0..self.num_rounds {
            // let mut node = root.clone();
            // while !node.can_add_child() && !node.is_terminal() {
            //     node = self
            //         .select_child(node)
            //         .expect("A selected child was not found");

            //     // Add a new child node into the tree.
            //     if node.can_add_child() {
            //         // node = node.add_random_child();
            //     }
            // }
        }

        Move {
            position: 0,
            piece: 0,
            next_piece: 1,
        }
    }

    // Selecte node with highest UCT score.
    pub fn select_child<'a>(&self, node: &'a Node) -> Option<&'a Node> {
        let mut total_rollouts = 0.0;
        for child in &node.children {
            total_rollouts += child.num_rollouts as f64;
        }

        let mut best_score = -1.0;
        let mut best_child = None;
        for child in &node.children {
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
}

#[cfg(test)]
mod tests {
    use super::super::Node;
    use super::*;
    use crate::game::{new_board, GameState};
    use std::collections::HashMap;

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
        let expected_child = node.children.last().unwrap();
        assert_eq!(agent.select_child(&node).unwrap(), expected_child);
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
