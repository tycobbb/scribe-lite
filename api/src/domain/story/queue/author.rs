use std::fmt;

// types
pub enum Author {
    Active,
    Waiting(Box<Fn(Position) + Send>)
}

#[derive(Debug, Serialize)]
pub struct Position {
    behind: usize
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

impl Position {
    // init / factories
    pub fn new(behind: usize) -> Position {
        Position {
            behind: behind
        }
    }

    // queries
    pub fn is_ready(&self) -> bool {
        self.behind == 0
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
