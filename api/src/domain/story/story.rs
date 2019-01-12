use domain::story::line::Line;

// types
pub struct Story {
    pub lines: Vec<Line>
}

// impls
impl Story {
    pub fn previous_line(&self) -> Option<&Line> {
        self.lines.last()
    }
}
