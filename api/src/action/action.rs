use serde::Serialize;
use core::errors;
use super::event::Event;

// types
// a command type that produces a serializable value or a user-facing error
pub trait Action {
    // fires the action and returns the payload
    fn call(&self) -> Event;
}

// a result type for actions
pub type Result<T> where T: Serialize =
    std::result::Result<T, Error>;

// a user-facing errors type
pub type Error = errors::Errors;
