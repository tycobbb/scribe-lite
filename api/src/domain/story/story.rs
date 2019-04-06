use chrono::{ DateTime, Utc };
use crate::domain::Id;
use super::line::Line;
use super::queue::{ Queue, Author, ActiveAuthor };
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

    // commands/lines
    pub fn add_line(&mut self,
        text:  String,
        name:  Option<String>,
        email: Option<String>
    ) {
        self.lines.push(Line::new(text, name, email));
        self.has_new_line = true;
    }

    // commands/queue
    pub fn join(&mut self, author_id: &Id) {
        self.queue.join(author_id);
    }

    pub fn leave(&mut self, author_id: &Id) {
        self.queue.leave(author_id);
    }

    pub fn rustle_active_author(&mut self, time: DateTime<Utc>) {
        self.queue.rustle_active_author(time);
    }

    pub fn remove_active_author(&mut self) {
        self.queue.remove_active_author();
    }

    // queries/lines
    pub fn new_line(&self) -> Option<&Line> {
        match self.has_new_line {
            true  => self.lines.last(),
            false => None
        }
    }

    pub fn next_line_prompt(&self) -> Prompt {
        match self.lines.last() {
            Some(line) => Prompt::from_line(line),
            None       => Prompt::default()
        }
    }

    // queries/queue
    pub fn active_author(&self) -> Option<ActiveAuthor> {
        self.queue.active_author()
    }

    pub fn new_author(&self) -> Option<Author> {
        self.queue.new_author()
    }

    pub fn authors_with_new_positions(&self) -> Vec<Author> {
        self.queue.authors_with_new_positions()
    }
}
