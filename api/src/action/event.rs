use crate::domain::story as model;
use super::story as action;

// types
#[derive(Debug)]
pub enum EventIn {
    // story
    AddLine(action::AddLine),
    CheckPulse1(action::CheckPulse),
    // shared
    NotFound
}

// Event is a list of events that actions can trigger.
#[derive(Debug)]
pub enum Event {
    // story
    ShowQueue(model::Position),
    ShowPrompt(model::Prompt),
    ShowThanks,
    CheckPulse1,
    // shared
    ShowInternalError
}

#[derive(Debug)]
pub enum Scheduled {
    CheckPulse1 = 0
}

// impls
impl Scheduled {
    pub fn from_raw(value: usize) -> Option<Scheduled> {
        match value {
            0 => Some(Scheduled::CheckPulse1),
            _ => None
        }
    }
}
