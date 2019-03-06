use core::socket;
use super::event::Event;

// types
#[derive(clone)]
pub struct Sink {
    sink: socket::Sink
}

// impls
impl Sink {
    pub fn send(&self, event: Event) {
        use socket::MessageOut;

        let message = match self {
            Event::ShowQueue(v)        => MessageOut::from_data(NameOut::ShowQueue, v),
            Event::ShowPrompt(v)       => MessageOut::from_data(NameOut::ShowPrompt, v),
            Event::ShowThanks          => MessageOut::from_name(NameOut::ShowThanks),
            Event::ShowAddLineError(e) => MessageOut::from_data(NameOut::ShowAddLineError, e),
            Event::ShowInternalError   => MessageOut::from_name(NameOut::ShowInternalError)
        }

        self.sink(message)
    }
}
