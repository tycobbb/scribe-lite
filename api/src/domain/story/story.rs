use super::queue::{ self, Author };
use super::line::Line;
use super::prompt::Prompt;

// types
#[derive(Debug)]
pub struct Story {
    pub id:           i32,
    pub lines:        Vec<Line>,
    pub has_new_line: bool,
}

// impls
impl Story {
    pub fn new(id: i32, lines: Vec<Line>) -> Self {
        Story {
            id:           id,
            lines:        lines,
            has_new_line: false
        }
    }

    // commands
    pub fn join(&mut self, author: Author) {
        let mut queue = queue::Repo.find_for_today();
        queue.join(author);
    }

    pub fn leave(&mut self) {
        let mut queue = queue::Repo.find_for_today();
        queue.leave();
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

    // queries
    pub fn is_available(&self) -> bool {
        let queue = queue::Repo.find_for_today();
        queue.is_empty()
    }

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
}
