use crate::action::action::Action;
use crate::action::event::{ Outbound, Scheduled };
use crate::action::routes::Sink;

// types
#[derive(Debug)]
pub struct TestPulse;

// impls
impl Action for TestPulse {
    type Args = ();

    fn new(_: ()) -> Self {
        TestPulse
    }

    fn call(self, _: Sink) {
    }
}
