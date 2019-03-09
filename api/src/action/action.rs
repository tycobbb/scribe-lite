use serde::Deserialize;
use super::routes::Sink;

// types
// a command type that can produce events
pub trait Action<'a> {
    type Args: Deserialize<'a>;

    // fires the action
    // - args:   the action's arguments, if any
    // - events: a sink for sending any produced events
    fn call(&self, args: Self::Args, sink: Sink);
}
