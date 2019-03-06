use serde::Deserialize;
use core::errors;
use super::routes::Sink;

// types
// a user-facing errors type
pub type Error = errors::Errors;

// a command type that produces a serializable value or a user-facing error
pub trait Action<'a> {
    type Args: Deserialize<'a>;

    // fires the action and returns the payload
    fn call(&self, args: Self::Args, sink: Sink);
}
