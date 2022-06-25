use super::NodeRef;

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

    pub fn select_child(&self, node: NodeRef) -> Option<NodeRef> {
        let mut total_rollouts = 0.0;
        for child in &node.borrow().children {
            total_rollouts += child.borrow().num_rollouts as f64;
        }

        let mut best_score = -1.0;
        let mut best_child = None;
        for child in &node.borrow().children {
            // Calculate the UCT score.
            let child_ref = child.borrow();
            let win_percentage =
                child_ref.winning_fraction(node.borrow().game_state.current_player);
            let exploration_factor =
                (total_rollouts.log10() / child_ref.num_rollouts as f64).sqrt();
            let uct_score = win_percentage + self.temperature * exploration_factor;
            if uct_score > best_score {
                best_score = uct_score;
                best_child = Some(child.clone());
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
        let node = Node::new_ref(game.clone(), None);
        let child_one = Node::new_ref(game.clone(), None);
        let child_two = Node::new_ref(game.clone(), None);
        let child_three = Node::new_ref(game, None);

        let mut win_counts = HashMap::new();
        win_counts.insert("agent", 3);

        child_one.borrow_mut().num_rollouts = 5;
        child_one.borrow_mut().win_counts = win_counts.clone();
        child_two.borrow_mut().num_rollouts = 4;
        child_two.borrow_mut().win_counts = win_counts.clone();
        child_three.borrow_mut().num_rollouts = 3;
        child_three.borrow_mut().win_counts = win_counts.clone();
        node.borrow_mut().children = vec![child_one, child_two, child_three.clone()];

        let agent = Agent::new(5, 1.0);
        assert_eq!(agent.select_child(node).unwrap(), child_three);
    }
}
