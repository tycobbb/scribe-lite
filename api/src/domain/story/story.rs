use domain::Id;
use super::line::Line;
use super::queue::{ Queue, Author };
use super::prompt::Prompt;

// types
#[derive(Debug)]
pub struct Story {
    pub id:           Id,
    pub(super) queue: Queue,
    pub(super) lines: Vec<Line>,
    pub has_new_line: bool
}

// impls
impl Story {
    pub fn new(id: Id, queue: Queue, lines: Vec<Line>) -> Self {
        Story {
            id:           id,
            queue:        queue,
            lines:        lines,
            has_new_line: false
        }
    }

    // commands
    pub fn join(&mut self, author_id: Id) {
        self.queue.join(author_id);
    }

    pub fn leave(&mut self, author_id: Id) {
        self.queue.leave(author_id);
    }

    pub fn add_line(&mut self,
        text:  &str,
        name:  Option<&str>,
        email: Option<&str>
    ) {
        self.lines.push(Line::new(
            text.into(),
            name.map(Into::into),
            email.map(Into::into)
        ));

        self.has_new_line = true
    }

    // queries/lines
    pub fn new_line(&self) -> Option<&Line> {
        if self.has_new_line {
            self.lines.last()
        } else {
            None
        }
    }

    pub fn previous_line(&self) -> Option<&Line> {
        if self.has_new_line {
            self.lines.get(self.lines.len() - 2)
        } else {
            self.lines.last()
        }
    }

    pub fn next_line_prompt(&self) -> Prompt {
        self.previous_line()
            .map(Prompt::from_line)
            .unwrap_or_default()
    }

    // queries/authors
    pub fn new_author(&self) -> Option<Author> {
        self.queue.new_author()
    }

    pub fn authors_with_new_positions(&self) -> Vec<Author> {
        self.queue.authors_with_new_positions()
    }
}
