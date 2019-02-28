use super::author::*;

// types
#[derive(Debug)]
pub struct Queue {
    authors: Vec<Author>
}

// impls
impl Queue {
    pub fn new() -> Self {
        Queue {
            authors: Vec::new()
        }
    }

    // commands
    pub fn join(&mut self, author: Author) {
        self.authors.push(author);
        self.notify_author(self.len() - 1);
    }

    pub fn leave(&mut self) {
        if self.authors.len() == 0 {
            warn!("attempted to leave an empty queue");
            return;
        }

        self.authors.remove(0);
        for i in 0..self.authors.len() {
            self.notify_author(i);
        }

        if self.authors.len() != 0 {
            self.authors[0] = Author::Active;
        }
    }

    fn notify_author(&self, index: usize) {
        if self.authors.len() == 0 {
            warn!("attempted to notify an author at an invalid index");
            return;
        }

        self.authors[index].notify(Position::new(index));
    }

    // queries
    fn len(&self) -> usize {
        self.authors.len()
    }

    pub fn is_empty(&self) -> bool {
        self.len() == 0
    }
}
