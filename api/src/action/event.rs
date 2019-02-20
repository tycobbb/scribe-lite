use domain::story;
use super::action;

// types
// events actions can trigger
#[derive(Debug)]
pub enum Event {
    ShowPreviousLine(action::Result<story::Prompt>),
    ShowThanks(action::Result<()>),
}
