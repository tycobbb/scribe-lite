use domain::story::line::Line;

// types
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
}
