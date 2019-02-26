use super::author::Author;

// types
#[derive(Debug)]
pub struct Queue {
    authors: Vec<Author>
}

#[derive(Debug)]
pub enum Position {
    Ready,
    Behind(usize)
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

    fn notify_author(&self, index: usize) {
        let position = if index == 0 {
            Position::Ready
        } else {
            Position::Behind(index)
        };

        self.authors[index].notify(position);
    }

    // queries
    fn len(&self) -> usize {
        self.authors.len()
    }

    pub fn is_empty(&self) -> bool {
        self.len() == 0
    }
}
