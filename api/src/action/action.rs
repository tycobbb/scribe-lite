use serde::Deserialize;
use core::errors;
use super::event::Event;

// types
// a command type that produces a serializable value or a user-facing error
pub trait Action<'a> {
    type Args: Deserialize<'a>;

    // fires the action and returns the payload
    fn call(&self, args: Self::Args, sink: Box<Fn(Event)>);
}

// a result type for actions
pub type Result<T> =
    std::result::Result<T, Error>;

// a user-facing errors type
pub type Error = errors::Errors;
