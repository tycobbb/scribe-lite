use crate::domain::story;
use serde_derive::Serialize;

// -- types --
#[derive(Debug)]
pub enum Outbound {
    ShowQueue(story::Position),
    ShowPrompt(story::Prompt),
    ShowThanks,
    CheckPulse,
    ShowDisconnected,
    ShowInternalError(Error),
}

#[derive(Debug)]
pub enum Scheduled {
    FindPulse = 0,
    TestPulse = 1,
}

#[derive(Debug, Serialize)]
pub struct Error {
    message: String,
}

// -- impls --
impl Outbound {
    pub fn show_error(error: &std::error::Error) -> Outbound {
        Outbound::ShowInternalError(Error {
            message: error.to_string(),
        })
    }
}

impl Scheduled {
    pub fn from_raw(value: usize) -> Option<Scheduled> {
        match value {
            0 => Some(Scheduled::FindPulse),
            1 => Some(Scheduled::TestPulse),
            _ => None,
        }
    }
}
