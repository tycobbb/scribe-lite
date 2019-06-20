use super::author::{ActiveAuthor, Author};
use crate::domain::Id;
use chrono::Utc;

// -- types --
#[derive(Debug)]
pub struct Queue {
    pub(super) author_ids: Vec<Id>,
    pub(super) author_pulse_millis: i64,
    pub has_new_author: bool,
    removed_author_index: Option<usize>,
}

// -- impls --
impl Queue {
    pub fn new(author_ids: Vec<Id>, author_pulse_millis: i64) -> Self {
        Queue {
            author_ids: author_ids,
            author_pulse_millis: author_pulse_millis,
            has_new_author: false,
            removed_author_index: None,
        }
    }

    // -- impls/commands/membership
    pub fn add_author(&mut self, author_id: &Id) {
        self.author_ids.push(author_id.clone());

        // track changes
        self.has_new_author = true;

        // if the active author joined, reset timer
        if self.author_ids.len() == 1 {
            self.author_pulse_millis = Utc::now().timestamp_millis();
        }
    }

    pub fn remove_author(&mut self, author_id: &Id) {
        if self.author_ids.is_empty() {
            return warn!("[story] attempted to leave an empty queue");
        }

        let pos = guard!(self.author_ids.iter().position(|id| id == author_id), else {
            return warn!("[story] attempted to remove an author that was not in the queue")
        });

        self.remove_author_at(pos);
    }

    fn remove_author_at(&mut self, index: usize) {
        self.author_ids.remove(index);

        // track changes
        self.removed_author_index = Some(index);

        // if the active author was removed, reset timer
        if index == 0 {
            self.author_pulse_millis = Utc::now().timestamp_millis();
        }
    }

    // -- impls/commands/pulse
    pub fn update_active_author_pulse(&mut self, millis: i64) {
        if self.author_ids.is_empty() {
            return warn!("[story] attempted to update the pulse for the author an empty queue");
        }

        self.author_pulse_millis = millis;
    }

    pub fn remove_active_author(&mut self) {
        if self.author_ids.is_empty() {
            return warn!("[story] attempted to remove the active author of an empty queue");
        }

        self.remove_author_at(0);
    }

    // -- impls/queries
    pub fn active_author(&self) -> Option<ActiveAuthor> {
        if self.author_ids.is_empty() {
            warn!("[story] attempted to get active author of an empty queue");
            return None;
        }

        Some(ActiveAuthor::new(
            &self.author_ids[0],
            self.author_pulse_millis,
        ))
    }

    pub fn new_author(&self) -> Option<Author> {
        if self.author_ids.is_empty() {
            warn!("[story] attempted to get active author of an empty queue");
            return None;
        }

        if !self.has_new_author {
            return None;
        }

        self.author_ids
            .last()
            .map(|id| self.make_author(id, self.author_ids.len() - 1))
    }

    pub fn authors_with_new_positions(&self) -> Vec<Author> {
        let index = guard!(self.removed_author_index, else {
            return Vec::new()
        });

        self.author_ids[index..]
            .iter()
            .enumerate()
            .map(|(i, id)| self.make_author(id, i))
            .collect()
    }

    // -- impls/queries/helpers
    fn make_author<'a>(&'a self, id: &'a Id, index: usize) -> Author<'a> {
        if index == 0 {
            Author::active(id, self.author_pulse_millis)
        } else {
            Author::queued(id, index)
        }
    }
}
