use super::{Node, NodeBuilder};
use crate::game::{GameState, Move, Player};
use rand::Rng;
use std::rc::Rc;

/* Monte Carlo Tree Search

 - create tree for given game state
 - start a round:
   - pick a leaf node
   - randomly place the active piece and choose the next piece
   - add new child node with this game state
   - execute rollout (simulate game from this node to see who wins)
   - record the win in this node
   - walkup all node ancestors and update their win counts
 - Set this to a certain number of rounds
   - Once limit is reached, select the child node of the root that has the highest win rate

*/
pub struct Agent {
    num_rounds: i32,
    temperature: f64, // For UCT - higher is volatile, lower is focused
}

impl Agent {
    pub fn new(num_rounds: i32, temperature: f64) -> Self {
        Self {
            num_rounds,
            temperature,
        }
    }

    pub fn select_move(&self, game: GameState) -> Move {
        let root = NodeBuilder::new(game).build();

        // If agent is given a winning move, take it!
        match root.borrow().game_state.winning_move() {
            Some(winning_move) => return winning_move,
            None => (),
        }

        for _ in 0..self.num_rounds {
            self.execute_round(root.clone());
        }

        // Having performed as many MCTS rounds as we have time for, we now pick a move.
        self.pick_best_move(root)
    }

    fn execute_round(&self, root: Node) {
        // Find a node to add a child to
        let mut node = root.clone();
        while !node.borrow().can_add_child() && !node.borrow().is_terminal() {
            node = self.select_child(node.clone());
        }

        // Add a new move into the tree
        if node.borrow().can_add_child() {
            node = self.add_child_for_random_move(node.clone());
        }

        // Simulate a random game from this node
        let winner = self.simulate_random_game(&node.borrow().game_state);
        node.borrow_mut().propagate_wins(winner);
    }

    // Select child node with highest UCT score.
    pub fn select_child(&self, node: Node) -> Node {
        let mut total_rollouts = 0.0;
        for child in &node.borrow().children {
            total_rollouts += child.borrow().num_rollouts as f64;
        }

        let mut best_score = -1.0;
        let mut best_child = None;
        for child in &node.borrow().children {
            let uct_score = self.calculate_uct_score(
                total_rollouts,
                child.borrow().num_rollouts as f64,
                child
                    .borrow()
                    .winning_fraction(node.borrow().game_state.current_player),
            );

            if uct_score > best_score {
                best_score = uct_score;
                best_child = Some(child.clone());
            }
        }
        best_child.expect("Child was not found")
    }

    // Calculate upper confidence bound for trees (UCT).
    // This gives you a balance between exploration (breadth) and exploitation (depth).
    fn calculate_uct_score(&self, parent_rollouts: f64, child_rollouts: f64, win_pct: f64) -> f64 {
        let exploration = (parent_rollouts.log10() / child_rollouts).sqrt();
        win_pct + self.temperature * exploration
    }

    fn add_child_for_random_move(&self, node: Node) -> Node {
        let next_move = node.borrow_mut().random_legal_move();
        let new_game_state = node.borrow().game_state.apply_move(&next_move);
        let child = NodeBuilder::new(new_game_state)
            .node_move(next_move)
            .parent(Rc::downgrade(&node))
            .build();
        node.borrow_mut().children.push(child);
        node.borrow().children.last().unwrap().clone()
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

    fn pick_best_move(&self, node: Node) -> Move {
        let mut best_move = None;
        let mut best_percent = -1.0;

        for child in &node.borrow().children {
            if self.is_losing_move(child.clone(), node.clone()) {
                continue;
            }

            let child_percent = child
                .borrow()
                .winning_fraction(node.borrow().game_state.current_player);

            if child_percent > best_percent {
                best_percent = child_percent;
                best_move = child.borrow().node_move.clone();
            }
        }

        if best_move.is_none() {
            best_move = node
                .borrow()
                .children
                .first()
                .unwrap()
                .borrow()
                .node_move
                .clone();
        }
        best_move.expect("Best move not found")
    }

    fn is_losing_move(&self, child: Node, parent: Node) -> bool {
        let child_ref = child.borrow();
        let child_move = child_ref.node_move.as_ref().unwrap();
        let new_game = parent.borrow().game_state.apply_move(child_move);
        for legal_move in new_game.legal_moves() {
            if new_game.apply_move(&legal_move).is_over() {
                return true;
            }
        }
        false
    }
}

#[cfg(test)]
mod tests {
    use super::super::{NodeBuilder, AGENT};
    use super::*;
    use crate::game::{new_board, GameState};
    use std::collections::HashMap;

    #[test]
    fn select_move_bug() {
        // cannot sample empty range
        let board = [
            None,
            Some(8),
            Some(2),
            None,
            Some(1),
            Some(13),
            Some(6),
            Some(9),
            Some(10),
            Some(5),
            Some(11),
            Some(14),
            None,
            Some(7),
            Some(0),
            None,
        ];
        let game = GameState::new(board, 3, AGENT);
        let agent = Agent::new(3000, 1.5);
        let selected_move = agent.select_move(game);
        assert!(selected_move.position >= 0);
    }

    #[test]
    fn select_move_returns_first_winning_move() {
        let mut board = new_board();
        board[0] = Some(0);
        board[1] = Some(2);
        board[2] = Some(4);
        let game = GameState::new(board, 8, AGENT);
        let agent = Agent::new(30, 1.0);
        let selected_move = agent.select_move(game);
        assert_eq!(selected_move.position, 3);
    }

    #[test]
    fn select_move_returns_random_move_when_they_all_lose() {
        let board = [
            None,
            Some(1),
            Some(2),
            Some(14),
            Some(15),
            None,
            Some(8),
            Some(6),
            None,
            None,
            Some(10),
            None,
            Some(11),
            Some(3),
            None,
            Some(5),
        ];
        let game = GameState::new(board, 0, AGENT);
        let agent = Agent::new(30, 1.0);
        let selected_move = agent.select_move(game);
        assert!(selected_move.position >= 0);
    }

    #[test]
    fn add_child_for_random_move_adds_new_node_to_tree() {
        let game = GameState::new(new_board(), 0, AGENT);
        let node = NodeBuilder::new(game).build();
        let agent = Agent::new(5, 1.0);
        agent.add_child_for_random_move(node.clone());
        assert_eq!(node.borrow().children.len(), 1);

        let node_ref = node.borrow();
        let child = node_ref.children.first().unwrap();
        assert!(child.borrow().node_move.is_some());
    }

    #[test]
    fn simulate_random_game_returns_the_winning_player() {
        let mut board = new_board();
        board[1] = Some(1);
        board[2] = Some(2);
        board[3] = Some(3);
        let game = GameState::new(board, 0, AGENT);
        let agent = Agent::new(5, 1.0);

        assert!(agent.simulate_random_game(&game).is_some());
    }

    #[test]
    fn select_child_works() {
        let game = GameState::new(new_board(), 0, AGENT);
        let node = NodeBuilder::new(game.clone()).build();
        let child_one = NodeBuilder::new(game.clone()).build();
        let child_two = NodeBuilder::new(game.clone()).build();
        let child_three = NodeBuilder::new(game).build();

        let mut win_counts = HashMap::new();
        win_counts.insert(AGENT, 3);

        child_one.borrow_mut().num_rollouts = 5;
        child_one.borrow_mut().win_counts = win_counts.clone();
        child_two.borrow_mut().num_rollouts = 4;
        child_two.borrow_mut().win_counts = win_counts.clone();
        child_three.borrow_mut().num_rollouts = 3;
        child_three.borrow_mut().win_counts = win_counts.clone();
        node.borrow_mut().children = vec![child_one, child_two, child_three];

        let agent = Agent::new(5, 1.0);
        let child = agent.select_child(node.clone());
        assert_eq!(child.borrow().num_rollouts, 3);
    }

    #[test]
    fn select_move_returns_a_move() {
        let agent = Agent::new(5, 1.0);
        let game = GameState::new(new_board(), 0, AGENT);
        let next_move = agent.select_move(game);
        assert!(next_move.next_piece > -1);
    }
}
