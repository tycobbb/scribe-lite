use crate::action::event::*;
use crate::action::routes::Sink;
use crate::action::action::Action;

// types
#[derive(Debug)]
pub struct CheckPulse;

// impls
impl Action for CheckPulse {
    type Args = ();

    fn new(_: ()) -> Self {
        CheckPulse
    }

    fn call(self, sink: Sink) {
        sink.send(Event::CheckPulse1)
    }
}
