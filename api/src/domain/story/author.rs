use std::fmt;
use super::queue::Position;

// types
pub enum Author {
    Active,
    Waiting(Box<Fn(Position)>)
}

// impls
impl Author {
    // commands
    pub fn notify(&self, position: Position) {
        if let Author::Waiting(handler) = self {
            handler(position);
        }
    }
}

impl fmt::Debug for Author {
    fn fmt(&self, f: &mut fmt::Formatter) -> fmt::Result {
        match self {
            Author::Active     => write!(f, "Author(Active)"),
            Author::Waiting(_) => write!(f, "Author(Waiting)")
        }
    }
}
