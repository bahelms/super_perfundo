use crate::game::{new_board, GameState, Move};
use rand::Rng;
use std::cell::RefCell;
use std::collections::HashMap;
use std::rc::Rc;

type NodeRef = Rc<RefCell<Node>>;

// Monte Carlo Tree Node
#[derive(Debug, PartialEq)]
pub struct Node {
    pub parent: Option<NodeRef>,
    pub children: Vec<NodeRef>,
    pub num_rollouts: i32,
    pub unvisited_moves: Vec<Move>,
    pub win_counts: HashMap<String, i32>,
    pub game_state: GameState,
    // pub move: Move,
}

impl Node {
    pub fn new(game_state: GameState) -> Self {
        let unvisited_moves = game_state.legal_moves();

        Self {
            game_state,
            unvisited_moves,
            parent: None,
            children: Vec::new(),
            num_rollouts: 0,
            win_counts: HashMap::new(),
        }
    }

    pub fn new_ref(game_state: GameState) -> NodeRef {
        Rc::new(RefCell::new(Self::new(game_state)))
    }

    pub fn add_child(parent: NodeRef, child: NodeRef) {
        child.borrow_mut().parent = Some(Rc::clone(&parent));
        parent.borrow_mut().children.push(child);
    }

    pub fn add_random_child(&mut self) {
        let mut rng = rand::thread_rng();
        let index: usize = rng.gen_range(0..self.unvisited_moves.len());
        // new_move = self.unvisited_moves.pop(index)
        // new_game_state = self.game_state.apply_move(new_move)
        // new_node = MCTSNode(new_game_state, self, new_move)
        // self.children.append(new_node)
        // return new_node
    }

    pub fn record_win(&mut self, winner: String) {
        let count = match self.win_counts.get(&winner) {
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

    fn setup() -> GameState {
        GameState::new(new_board(), 0)
    }

    #[test]
    fn new_returns_an_initialized_node() {
        let node = Node::new(setup());
        assert_eq!(node.num_rollouts, 0);
        assert_eq!(node.parent, None);
        assert_eq!(node.children, Vec::new());
    }

    #[test]
    fn node_has_children() {
        let root = Node::new_ref(setup());
        Node::add_child(Rc::clone(&root), Node::new_ref(setup()));
        let child = &root.borrow().children[0];

        assert_eq!(child.borrow().num_rollouts, 0);
        assert_eq!(
            child
                .borrow()
                .parent
                .as_ref()
                .unwrap()
                .borrow()
                .num_rollouts,
            0
        );
    }

    #[test]
    fn record_win_increments_the_wins_for_player() {
        let root = Node::new_ref(setup());
        root.borrow_mut().record_win("player".to_string());
        root.borrow_mut().record_win("player".to_string());
        root.borrow_mut().record_win("ai".to_string());
        assert_eq!(root.borrow().win_counts.get("player").unwrap(), &2);
        assert_eq!(root.borrow().win_counts.get("ai").unwrap(), &1);
    }

    #[test]
    fn record_win_increments_the_number_of_rollouts() {
        let root = Node::new_ref(setup());
        root.borrow_mut().record_win("player".to_string());
        root.borrow_mut().record_win("player".to_string());
        root.borrow_mut().record_win("ai".to_string());
        assert_eq!(root.borrow().num_rollouts, 3);
    }

    #[test]
    fn add_random_child_adds_new_node_to_tree() {
        let root = Node::new_ref(setup());
        root.borrow_mut().add_random_child();
        assert_eq!(root.borrow().children.len(), 1);
    }
}
