use domain::story;
use super::action;

// types
// events actions can trigger
#[derive(Debug)]
pub enum Event {
    ShowPrompt(action::Result<story::Prompt>),
    ShowThanks(action::Result<()>),
}
