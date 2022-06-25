use crate::game::{GameState, Move};
use rand::Rng;
use std::cell::RefCell;
use std::collections::HashMap;
use std::rc::Rc;

pub type NodeRef = Rc<RefCell<Node>>;

// Monte Carlo Tree Node
#[derive(Debug, PartialEq)]
pub struct Node {
    pub parent: Option<NodeRef>,
    pub children: Vec<NodeRef>,
    pub num_rollouts: i32,
    pub unvisited_moves: Vec<Move>,
    pub win_counts: HashMap<&'static str, i32>,
    pub game_state: GameState,
    pub current_move: Option<Move>,
}

impl Node {
    pub fn new(game_state: GameState, current_move: Option<Move>) -> Self {
        let unvisited_moves = game_state.legal_moves();
        let mut win_counts = HashMap::new();
        win_counts.insert("agent", 0);
        win_counts.insert("player", 0);

        Self {
            game_state,
            current_move,
            unvisited_moves,
            win_counts,
            parent: None,
            children: Vec::new(),
            num_rollouts: 0,
        }
    }

    pub fn new_ref(game_state: GameState, current_move: Option<Move>) -> NodeRef {
        Rc::new(RefCell::new(Self::new(game_state, current_move)))
    }

    pub fn add_random_child(&mut self) {
        let mut rng = rand::thread_rng();
        let index: usize = rng.gen_range(0..self.unvisited_moves.len());
        let next_move = self.unvisited_moves.swap_remove(index);
        // new_game_state = self.game_state.apply_move(new_move)
        let new_node = Node::new_ref(self.game_state.clone(), Some(next_move));
        self.children.push(new_node);
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

    pub fn record_win(&mut self, winner: &'static str) {
        let count = match self.win_counts.get(winner) {
            Some(count) => *count,
            None => 0,
        };
        self.win_counts.insert(winner, count + 1);
        self.num_rollouts += 1;
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use crate::game::new_board;

    fn setup() -> GameState {
        GameState::new(new_board(), 0, "agent")
    }

    fn setup_finished_game() -> GameState {
        let mut board = new_board();
        board[0] = Some(0);
        board[1] = Some(2);
        board[2] = Some(4);
        board[3] = Some(8);
        GameState::new(board, 15, "agent")
    }

    #[test]
    fn new_returns_an_initialized_node() {
        let node = Node::new(setup(), None);
        assert_eq!(node.num_rollouts, 0);
        assert_eq!(node.parent, None);
        assert_eq!(node.children, Vec::new());
    }

    #[test]
    fn record_win_increments_the_wins_for_player() {
        let root = Node::new_ref(setup(), None);
        root.borrow_mut().record_win("player");
        root.borrow_mut().record_win("player");
        root.borrow_mut().record_win("ai");
        assert_eq!(root.borrow().win_counts.get("player").unwrap(), &2);
        assert_eq!(root.borrow().win_counts.get("ai").unwrap(), &1);
    }

    #[test]
    fn record_win_increments_the_number_of_rollouts() {
        let root = Node::new_ref(setup(), None);
        root.borrow_mut().record_win("player");
        root.borrow_mut().record_win("player");
        root.borrow_mut().record_win("ai");
        assert_eq!(root.borrow().num_rollouts, 3);
    }

    #[test]
    fn add_random_child_adds_new_node_to_tree() {
        let root = Node::new_ref(setup(), None);
        root.borrow_mut().add_random_child();
        assert_eq!(root.borrow().children.len(), 1);
    }

    #[test]
    fn can_add_child_returns_true_with_unvisited_moves() {
        let root = Node::new_ref(setup(), None);
        assert!(root.borrow().can_add_child());
    }

    #[test]
    fn can_add_child_returns_false_with_no_unvisited_moves() {
        let root = Node::new_ref(setup(), None);
        let mut root_ref = root.borrow_mut();
        root_ref.unvisited_moves = Vec::new();
        assert_eq!(root_ref.can_add_child(), false);
    }

    #[test]
    fn is_terminal_returns_true_when_game_is_over() {
        let root = Node::new_ref(setup_finished_game(), None);
        assert!(root.borrow().is_terminal());
    }

    #[test]
    fn is_terminal_returns_false_when_game_is_not_over() {
        let root = Node::new_ref(setup(), None);
        assert_eq!(root.borrow().is_terminal(), false);
    }

    #[test]
    fn winning_fraction_returns_win_percentage_for_given_player() {
        let root = Node::new_ref(setup(), None);
        let mut root_ref = root.borrow_mut();
        root_ref.win_counts.insert("agent", 28);
        root_ref.win_counts.insert("player", 22);
        root_ref.num_rollouts = 50;
        assert_eq!(root_ref.winning_fraction("player"), 0.44);
        assert_eq!(root_ref.winning_fraction("agent"), 0.56);
    }
}
