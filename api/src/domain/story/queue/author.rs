use crate::domain::Id;
use chrono::{DateTime, Duration, Utc};
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
    pub rustle_time: &'a DateTime<Utc>,
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
    pub fn active(id: &'a Id, rustle_time: &'a DateTime<Utc>) -> Author<'a> {
        Author::Active(ActiveAuthor::new(id, rustle_time))
    }

    pub fn queued(id: &'a Id, behind: usize) -> Author<'a> {
        Author::Queued(QueuedAuthor::new(id, behind))
    }
}

impl<'a> ActiveAuthor<'a> {
    pub fn new(id: &'a Id, rustle_time: &'a DateTime<Utc>) -> ActiveAuthor<'a> {
        ActiveAuthor {
            id: id,
            rustle_time: rustle_time,
        }
    }

    // -- impls/queries
    pub fn idle_duration(&self) -> Duration {
        Utc::now() - *self.rustle_time
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
