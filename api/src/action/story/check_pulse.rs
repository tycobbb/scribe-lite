use action::event::*;
use action::routes::Sink;
use action::action::Action;

// types
pub struct CheckPulse;

// impls
impl<'a> Action<'a> for CheckPulse {
    type Args = ();

    fn call(&self, _: (), sink: Sink) {
        sink.send(Event::CheckPulse1)
    }
}
