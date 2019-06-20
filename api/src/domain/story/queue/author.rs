use crate::domain::Id;
use chrono::Utc;
use serde_derive::Serialize;

// -- types --
#[derive(Debug)]
pub enum Author<'a> {
    Active(ActiveAuthor<'a>),
    Queued(QueuedAuthor<'a>),
}

#[derive(Debug)]
pub struct ActiveAuthor<'a> {
    pub id: &'a Id,
    pub pulse_millis: i64,
}

#[derive(Debug)]
pub struct QueuedAuthor<'a> {
    pub id: &'a Id,
    pub position: Position,
}

#[derive(Debug, Serialize, Clone)]
pub struct Position {
    pub behind: usize,
}

// -- impls --
impl<'a> Author<'a> {
    // factories
    pub fn active(id: &'a Id, pulse_millis: i64) -> Author<'a> {
        Author::Active(ActiveAuthor::new(id, pulse_millis))
    }

    pub fn queued(id: &'a Id, behind: usize) -> Author<'a> {
        Author::Queued(QueuedAuthor::new(id, behind))
    }
}

impl<'a> ActiveAuthor<'a> {
    pub fn new(id: &'a Id, pulse_millis: i64) -> ActiveAuthor<'a> {
        ActiveAuthor {
            id: id,
            pulse_millis: pulse_millis,
        }
    }

    // -- impls/queries
    pub fn is_idle(&self) -> bool {
        self.idle_millis() >= 60 * 1000
    }

    pub fn idle_millis(&self) -> i64 {
        std::cmp::max(Utc::now().timestamp_millis() - self.pulse_millis, 0)
    }

    pub fn find_pulse_at_millis(&self) -> i64 {
        std::cmp::max(30 * 1000 - self.idle_millis(), 0)
    }
}

impl<'a> QueuedAuthor<'a> {
    pub fn new(id: &'a Id, behind: usize) -> QueuedAuthor {
        QueuedAuthor {
            id: id,
            position: Position { behind: behind },
        }
    }
}
