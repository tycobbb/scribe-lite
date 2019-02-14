use serde::Serialize;
use core::action;
use domain::story;

// types
// events actions can trigger
#[derive(Debug)]
pub enum Event<'a> {
    ShowPreviousLine(action::Result<'a, story::Prompt>),
    ShowThanks(action::Result<'a, ()>),
}
