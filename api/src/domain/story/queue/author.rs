use chrono::NaiveDateTime;
use serde_derive::Serialize;
use crate::domain::Id;

// types
#[derive(Debug)]
pub enum Author {
    Writer(Id, Option<NaiveDateTime>),
    Waiter(Id, Position)
}

#[derive(Debug, Serialize, Clone)]
pub struct Position {
    pub behind: usize
}

// impls
impl Author {
    // TODO: as a concept, it's probably more accurate to call all authors "writers".
    // TODO: the way that Author is evolving feels wrong. too many methods that fail if
    // called on the wrong type of author, and we always know at call site which type of
    // author we expect to act on and where it would be in the vec. it may work better
    // to have the active writer be an owned relation of the story and the other
    // writers be part of the queue. alt, just keep the active writer out of the vec, but
    // still managed by the queue.

    // commands
    pub fn become_writer(&mut self) {
        match self {
            Author::Writer(_,  _) => warn!("[story] tried to call #start_writing on a writer"),
            Author::Waiter(id, _) => *self = Author::writer(id.clone(), None)
        };
    }

    pub fn rustle(&mut self, time: NaiveDateTime) {
        match self {
            Author::Writer(id,  _) => *self = Author::writer(id.clone(), Some(time)),
            Author::Waiter(_ , _) => warn!("[story] tried to call #touch on a waiter")
        };
    }

    // accessors
    pub fn id(&self) -> &Id {
        match self {
            Author::Writer(id, _) => id,
            Author::Waiter(id, _) => id
        }
    }

    pub fn last_active_at(&self) -> Option<NaiveDateTime> {
        match self {
            Author::Writer(_, time) => *time,
            Author::Waiter(_, _)    => None
        }
    }

    // factories
    pub fn writer(id: Id, last_active_at: Option<NaiveDateTime>) -> Author {
        Author::Writer(id, last_active_at)
    }

    pub fn waiter(id: Id, behind: usize) -> Author {
        Author::Waiter(id, Position {
            behind: behind
        })
    }
}
