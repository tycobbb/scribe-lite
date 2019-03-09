use domain::Id;
use super::author::Author;

// types
#[derive(Debug)]
pub struct Queue {
    pub(super) author_ids: Vec<Id>,
    pub has_new_author:    bool,
    removed_author_index:  Option<usize>
}


// impls
impl Queue {
    pub fn new(author_ids: Vec<Id>) -> Self {
        Queue {
            author_ids:           author_ids,
            has_new_author:       false,
            removed_author_index: None,
        }
    }

    // commands
    pub fn join(&mut self, author_id: Id) {
        self.has_new_author = true;
        self.author_ids.push(author_id);
    }

    pub fn leave(&mut self, author_id: Id) {
        if self.author_ids.len() == 0 {
            warn!("attempted to leave an empty queue");
            return
        }

        let position = self.author_ids.iter().position(|id| id == &author_id);
        let index = match position {
            Some(i) => i,
            None    => return warn!("attempted to remove an author that was not in the queue")
        };

        self.author_ids.remove(index);
    }

    // queries
    pub fn new_author(&self) -> Option<Author> {
        if !self.has_new_author {
            return None
        }

        let index = self.author_ids.len() - 1;
        let id    = &self.author_ids[index];
        Some(Author::new(id, index))
    }

    pub fn authors_with_new_positions(&self) -> Vec<Author> {
        let mut authors = Vec::new();

        let index = match self.removed_author_index {
            Some(i) => i,
            None    => return authors
        };

        let ids = &self.author_ids[index..];
        for (index, id) in ids.iter().enumerate() {
            authors.push(Author::new(id, index));
        }

        authors
    }
}
