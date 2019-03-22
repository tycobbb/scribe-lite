use serde::{ Serialize, Deserialize };
use crate::core::Id;
use crate::core::socket::{ self, NameOut };
use super::action::Action;
use super::event::*;
use super::story;

// types
#[derive(Clone)]
pub struct Routes;

#[derive(Clone)]
pub struct Sink {
    sink: socket::Sink
}

// impls
impl socket::Routes for Routes {
    // commands
    fn connect(&self, sink: socket::Sink) {
        story::Join.call(Sink::new(sink));
    }

    fn on_message<'a>(&self, msg: socket::MessageIn<'a>, sink: socket::Sink) -> socket::Result<()> {
        fn to_action<'a, A, T>(
            event: fn(A) -> EventIn,
            msg:   socket::MessageIn<'a>
        ) -> socket::Result<EventIn> where A: Action<Args=T>, T: Deserialize<'a> {
            msg.decode_args().map(|args| event(A::new(args)))
        }

        let action = match msg.name {
            "ADD_LINE"      => to_action(EventIn::AddLine, msg),
            "CHECK_PULSE_1" => to_action(EventIn::CheckPulse1, msg),
            _               => return Ok(error!("[routes] received unknown msg={:?}", msg))
        };

        action.map(|event| {
            self.execute(event, sink)
        })
    }

    fn on_timeout(&self, timeout: socket::Timeout, sink: socket::Sink) -> socket::Result<()> {
        fn to_action<'a, A>(
            event: fn(A) -> EventIn,
        ) -> EventIn where A: Action<Args=()> {
            event(A::new(()))
        }

        let scheduled = match Scheduled::from_raw(timeout.value()) {
            Some(scheduled) => scheduled,
            None            => return Ok(error!("[routes] received unknown timeout={:?}", timeout))
        };

        let action = match scheduled {
            Scheduled::CheckPulse1 => to_action(EventIn::CheckPulse1)
        };

        self.execute(action, sink);
        Ok(())
    }

    fn disconnect(&self, sink: socket::Sink) {
        story::Leave.call(Sink::new(sink));
    }
}

impl Routes {
    fn execute(&self, event: EventIn, sink: socket::Sink) {
        let sink = Sink::new(sink);

        match event {
            EventIn::AddLine(action)     => action.call(sink),
            EventIn::CheckPulse1(action) => action.call(sink),
            EventIn::NotFound            => return
        };
    }
}

impl Sink {
    // init
    pub fn new(sink: socket::Sink) -> Self {
        Sink {
            sink: sink
        }
    }

    // props
    pub fn id(&self) -> &Id {
        &self.sink.id
    }

    // commands
    pub fn send(&self, event: Event) {
        self.send_to(self.id(), event);
    }

    pub fn send_to(&self, id: &Id, event: Event) {
        // helper
        fn to_message<T>(name: NameOut, value: T) -> socket::Result<socket::MessageOut> where T: Serialize {
            socket::MessageOut::encoding_data(name, value)
        }

        // routes/out
        let message = match event {
            Event::ShowQueue(v)        => to_message(NameOut::ShowQueue, v),
            Event::ShowPrompt(v)       => to_message(NameOut::ShowPrompt, v),
            Event::ShowThanks          => to_message(NameOut::ShowThanks, ()),
            Event::ShowInternalError   => to_message(NameOut::ShowInternalError, ()),
            Event::CheckPulse1         => to_message(NameOut::CheckPulse, ())
        };

        self.sink.send_to(id, message);
    }

    pub fn schedule(&self, ms: u64, event: Event) {
        self.schedule_for(self.id(), ms, event)
    }

    pub fn schedule_for(&self, id: &Id, ms: u64, event: Event) {
        let scheduled = match event {
            Event::CheckPulse1 => socket::Timeout::new(Scheduled::CheckPulse1 as usize),
            _                  => return error!("[routes] attempted to schedule unhandled event={:?}", event)
        };

        self.sink.schedule_for(id, ms, scheduled);
    }
}
