use crate::domain::story as model;

// types
#[derive(Debug)]
pub enum Outbound {
    ShowQueue(model::Position),
    ShowPrompt(model::Prompt),
    ShowThanks,
    CheckPulse,
    ShowDisconnected,
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
