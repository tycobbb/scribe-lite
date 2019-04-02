use chrono::NaiveDateTime;
use crate::domain::Id;
use super::author::Author;

// types
#[derive(Debug)]
pub struct Queue {
    authors:              Vec<Author>,
    pub has_new_author:   bool,
    removed_author_index: Option<usize>
}

// impls
impl Queue {
    pub fn new(authors: Vec<Author>) -> Self {
        Queue {
            authors:              authors,
            has_new_author:       false,
            removed_author_index: None,
        }
    }

    // commands
    pub fn join(&mut self, author_id: &Id) {
        self.has_new_author = true;

        let author_id = author_id.clone();
        let author    = if self.authors.is_empty() {
            Author::writer(author_id, None)
        } else {
            Author::waiter(author_id, self.authors.len())
        };

        self.authors.push(author)
    }

    pub fn leave(&mut self, author_id: &Id) {
        if self.authors.is_empty() {
            warn!("[story] attempted to leave an empty queue");
            return
        }

        let index = match self.authors.iter().position(|a| a.id() == author_id) {
            Some(i) => i,
            None    => return warn!("[story] attempted to remove an author that was not in the queue")
        };

        // remove the author
        self.authors.remove(index);
        self.removed_author_index = Some(index);

        // if it was the writer, tell the new author to write
        if index == 0 && !self.authors.is_empty() {
            self.authors[0].become_writer();
        }
    }

    pub fn touch(&mut self, time: NaiveDateTime) {
        if self.authors.is_empty() {
            warn!("[story] attempted to leave an empty queue");
            return
        }

        self.authors[0].touch(time);
    }

    // queries
    pub fn last_active_at(&self) -> Option<NaiveDateTime> {
        self.authors
            .first()
            .and_then(|author| author.last_active_at())
    }

    pub fn new_author(&self) -> Option<&Author> {
        if !self.has_new_author {
            None
        } else {
            self.authors.last()
        }
    }

    pub fn authors_with_new_positions(&self) -> &[Author] {
        let index = self.removed_author_index
            // default to len for an empty slice
            .unwrap_or(self.authors.len());

        &self.authors[index..]
    }

    // accessors
    pub fn author_ids(&self) -> Vec<&Id> {
        self.authors.iter().map(|author| author.id()).collect()
    }
}
