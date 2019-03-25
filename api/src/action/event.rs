use crate::domain::story as model;
use super::story as action;

// types
#[derive(Debug)]
pub enum Inbound {
    // story
    AddLine(action::AddLine),
    FindPulse(action::FindPulse),
    TestPulse(action::TestPulse)
}

#[derive(Debug)]
pub enum Outbound {
    // story
    ShowQueue(model::Position),
    ShowPrompt(model::Prompt),
    ShowThanks,
    FindPulse,
    // shared
    ShowInternalError
}

#[derive(Debug)]
pub enum Scheduled {
    FindPulse = 0,
    TestPulse = 1
}

// impls
impl Scheduled {
    pub fn from_raw(value: usize) -> Option<Scheduled> {
        match value {
            0 => Some(Scheduled::FindPulse),
            1 => Some(Scheduled::TestPulse),
            _ => None
        }
    }
}
