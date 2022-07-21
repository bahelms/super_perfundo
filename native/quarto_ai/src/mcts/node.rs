use crate::game::{GameState, Move};
use rand::Rng;
use std::cell::RefCell;
use std::collections::HashMap;
use std::rc::{Rc, Weak};

pub const PLAYER: &'static str = "player";
pub const AGENT: &'static str = "agent";

pub type Node = Rc<RefCell<NodeData>>;
pub type WeakNode = Weak<RefCell<NodeData>>;

pub trait NodeBuilder {
    fn new(game_state: GameState) -> Self;
}

impl NodeBuilder for Node {
    fn new(game_state: GameState) -> Node {
        Rc::new(RefCell::new(NodeData::new(game_state)))
    }
}

// Monte Carlo Tree Node
#[derive(Debug, Clone)]
pub struct NodeData {
    pub game_state: GameState,
    pub children: Vec<Node>,
    pub num_rollouts: i32,
    pub unvisited_moves: Vec<Move>,
    pub win_counts: HashMap<&'static str, i32>,
    pub parent: Option<WeakNode>,
    // pub current_move: Option<Move>,
}

impl NodeData {
    pub fn new(game_state: GameState) -> Self {
        let unvisited_moves = game_state.legal_moves();
        let mut win_counts = HashMap::new();
        win_counts.insert(AGENT, 0);
        win_counts.insert(PLAYER, 0);

        Self {
            game_state,
            children: Vec::new(),
            num_rollouts: 0,
            unvisited_moves,
            win_counts,
            parent: None,
        }
    }

    pub fn random_legal_move(&mut self) -> Move {
        let mut rng = rand::thread_rng();
        let index: usize = rng.gen_range(0..self.unvisited_moves.len());
        self.unvisited_moves.swap_remove(index)
    }

    pub fn can_add_child(&self) -> bool {
        self.unvisited_moves.len() > 0
    }

    pub fn is_terminal(&self) -> bool {
        self.game_state.is_over()
    }

    pub fn winning_fraction(&self, player: &str) -> f64 {
        let wins = *self.win_counts.get(player).unwrap() as f64;
        wins / self.num_rollouts as f64
    }

    pub fn record_win(&mut self, winner: Option<&'static str>) {
        if let Some(player) = winner {
            let count = match self.win_counts.get(player) {
                Some(count) => *count,
                None => 0,
            };
            self.win_counts.insert(player, count + 1);
        }
        self.num_rollouts += 1;
    }

    // Record win and propagate it back up the tree.
    pub fn propagate_wins(&mut self, winner: Option<&'static str>) {
        self.record_win(winner);

        if let Some(parent_node) = self.parent.clone() {
            let parent = parent_node.upgrade().unwrap();
            parent.borrow_mut().propagate_wins(winner);
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::game::new_board;

    fn setup() -> GameState {
        GameState::new(new_board(), 0, AGENT)
    }

    fn setup_finished_game() -> GameState {
        let mut board = new_board();
        board[0] = Some(0);
        board[1] = Some(2);
        board[2] = Some(4);
        board[3] = Some(8);
        GameState::new(board, 15, AGENT)
    }

    #[test]
    fn propagate_scores_records_win_for_every_parent_in_the_branch() {
        let root: Node = NodeBuilder::new(setup());
        let child: Node = NodeBuilder::new(setup());
        let grand_child: Node = NodeBuilder::new(setup());

        child.borrow_mut().parent = Some(Rc::downgrade(&root));
        grand_child.borrow_mut().parent = Some(Rc::downgrade(&child));
        child.borrow_mut().children.push(grand_child.clone());
        root.borrow_mut().children.push(child.clone());

        grand_child.borrow_mut().propagate_wins(Some(AGENT));
        assert_eq!(grand_child.borrow().win_counts.get(AGENT).unwrap(), &1);
        assert_eq!(child.borrow().win_counts.get(AGENT).unwrap(), &1);
        assert_eq!(root.borrow().win_counts.get(AGENT).unwrap(), &1);
    }

    #[test]
    fn new_returns_an_initialized_node() {
        let node: Node = NodeBuilder::new(setup());
        assert_eq!(node.borrow().num_rollouts, 0);
        assert!(node.borrow().children.is_empty());
    }

    #[test]
    fn record_win_increments_the_wins_for_player() {
        let root: Node = NodeBuilder::new(setup());
        root.borrow_mut().record_win(Some(PLAYER));
        root.borrow_mut().record_win(Some(PLAYER));
        root.borrow_mut().record_win(Some(AGENT));
        assert_eq!(root.borrow().win_counts.get(PLAYER).unwrap(), &2);
        assert_eq!(root.borrow().win_counts.get(AGENT).unwrap(), &1);
    }

    #[test]
    fn record_win_increments_the_number_of_rollouts() {
        let root: Node = NodeBuilder::new(setup());
        root.borrow_mut().record_win(Some(PLAYER));
        root.borrow_mut().record_win(Some(PLAYER));
        root.borrow_mut().record_win(Some(AGENT));
        assert_eq!(root.borrow().num_rollouts, 3);
    }

    #[test]
    fn record_win_increments_the_number_of_rollouts_with_no_winner() {
        let root: Node = NodeBuilder::new(setup());
        root.borrow_mut().record_win(None);
        root.borrow_mut().record_win(None);
        root.borrow_mut().record_win(None);
        assert_eq!(root.borrow().num_rollouts, 3);
        assert_eq!(root.borrow().win_counts.get(PLAYER).unwrap(), &0);
        assert_eq!(root.borrow().win_counts.get(AGENT).unwrap(), &0);
    }

    #[test]
    fn can_add_child_returns_true_with_unvisited_moves() {
        let root: Node = NodeBuilder::new(setup());
        assert!(root.borrow().can_add_child());
    }

    #[test]
    fn can_add_child_returns_false_with_no_unvisited_moves() {
        let root: Node = NodeBuilder::new(setup());
        root.borrow_mut().unvisited_moves = Vec::new();
        assert_eq!(root.borrow().can_add_child(), false);
    }

    #[test]
    fn is_terminal_returns_true_when_game_is_over() {
        let root: Node = NodeBuilder::new(setup_finished_game());
        assert!(root.borrow().is_terminal());
    }

    #[test]
    fn is_terminal_returns_false_when_game_is_not_over() {
        let root: Node = NodeBuilder::new(setup());
        assert_eq!(root.borrow().is_terminal(), false);
    }

    #[test]
    fn winning_fraction_returns_win_percentage_for_given_player() {
        let root: Node = NodeBuilder::new(setup());
        root.borrow_mut().win_counts.insert(AGENT, 28);
        root.borrow_mut().win_counts.insert(PLAYER, 22);
        root.borrow_mut().num_rollouts = 50;
        assert_eq!(root.borrow().winning_fraction(PLAYER), 0.44);
        assert_eq!(root.borrow().winning_fraction(AGENT), 0.56);
    }
}
