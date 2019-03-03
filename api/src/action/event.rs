use domain::story;
use super::action;

// types
// Event is a list of events that actions can trigger.
#[derive(Debug)]
pub enum Event {
    // story
    ShowQueue(story::Position),
    ShowPrompt(story::Prompt),
    ShowThanks,
    ShowAddLineError(action::Error),
    // shared
    ShowInternalError
}
