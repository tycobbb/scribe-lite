use super::routes::Sink;

// -- types --
// a command type that can produce events
pub trait Action {
    type Args;

    // -- init --s an action
    // - args:   the action's arguments, if any
    fn new(args: Self::Args) -> Self;

    // fires the action
    // - events: a sink for sending any produced events
    fn call(self, sink: Sink);
}
