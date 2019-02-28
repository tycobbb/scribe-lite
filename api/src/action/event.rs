use domain::story;
use super::action;

// types
// events actions can trigger
#[derive(Debug)]
pub enum Event {
    ShowPrompt(action::Result<story::Prompt>),
    ShowQueue(action::Result<story::Position>),
    ShowThanks(action::Result<()>),
    ShowInternalError
}
