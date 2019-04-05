use chrono::{ DateTime, Duration, Utc };
use serde_derive::Serialize;
use crate::domain::Id;

// types
#[derive(Debug)]
pub enum Author<'a> {
    Active(ActiveAuthor<'a>),
    Queued(QueuedAuthor<'a>)
}

#[derive(Debug)]
pub struct ActiveAuthor<'a> {
    pub id:          &'a Id,
    pub rustle_time: Option<&'a DateTime<Utc>>
}

#[derive(Debug)]
pub struct QueuedAuthor<'a> {
    pub id:       &'a Id,
    pub position: Position
}

#[derive(Debug, Serialize, Clone)]
pub struct Position {
    pub behind: usize
}

// impls
impl<'a> Author<'a> {
    // factories
    pub fn active(id: &'a Id, rustle_time: &'a Option<DateTime<Utc>>) -> Author<'a> {
        Author::Active(ActiveAuthor::new(id, rustle_time))
    }

    pub fn queued(id: &'a Id, behind: usize) -> Author<'a> {
        Author::Queued(QueuedAuthor::new(id, behind))
    }
}

impl<'a> ActiveAuthor<'a> {
    pub fn new(id: &'a Id, rustle_time: &'a Option<DateTime<Utc>>) -> ActiveAuthor<'a> {
        ActiveAuthor {
            id:          id,
            rustle_time: rustle_time.as_ref(),
        }
    }

    // queries
    pub fn idle_time(&self) -> Option<Duration> {
        self.rustle_time.map(|time| Utc::now() - *time)
    }
}

impl<'a> QueuedAuthor<'a> {
    pub fn new(id: &'a Id, behind: usize) -> QueuedAuthor {
        QueuedAuthor {
            id: id,
            position: Position {
                behind: behind
            }
        }
    }
}
