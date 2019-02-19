use serde::Serialize;
use core::action;
use domain::story;

// types
// events actions can trigger
#[derive(Debug)]
pub enum Event {
    ShowPreviousLine(action::Result<story::Prompt>),
    ShowThanks(action::Result<()>),
}
