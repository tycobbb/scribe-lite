use serde_derive::Serialize;
use super::line::Line;

// types
#[derive(Debug, Serialize)]
pub struct Prompt {
    text: String,
    name: Option<String>
}

// impls
impl Prompt {
    pub fn from_line(line: &Line) -> Self {
        Prompt {
            text: line.text.clone(),
            name: line.name.clone()
        }
    }
}

impl Default for Prompt {
    fn default() -> Self {
        Prompt {
            text: "You get to write the first line! Follow your heart <3".to_string(),
            name: None
        }
    }
}
