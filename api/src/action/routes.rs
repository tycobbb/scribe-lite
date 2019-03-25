use serde::{ Serialize, Deserialize };
use crate::core::Id;
use crate::core::socket;
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
        fn to_event<'a, A, T>(
            event: fn(A) -> Inbound,
            msg:   socket::MessageIn<'a>
        ) -> socket::Result<Inbound> where A: Action<Args=T>, T: Deserialize<'a> {
            msg.decode_args().map(|args| event(A::new(args)))
        }

        let result = match msg.name {
            "ADD_LINE" => to_event(Inbound::AddLine, msg),
            _          => return Ok(error!("[routes] received unknown msg={:?}", msg))
        };

        result.map(|event| {
            self.execute(event, sink);
        })
    }

    fn on_timeout(&self, timeout: socket::Timeout, sink: socket::Sink) -> socket::Result<()> {
        fn to_action<'a, A>(
            event: fn(A) -> Inbound,
        ) -> Inbound where A: Action<Args=()> {
            event(A::new(()))
        }

        let scheduled = match Scheduled::from_raw(timeout.value()) {
            Some(scheduled) => scheduled,
            None            => return Ok(error!("[routes] received unknown timeout={:?}", timeout))
        };

        let action = match scheduled {
            Scheduled::FindPulse => to_action(Inbound::FindPulse),
            Scheduled::TestPulse => to_action(Inbound::TestPulse)
        };

        self.execute(action, sink);
        Ok(())
    }

    fn disconnect(&self, sink: socket::Sink) {
        story::Leave.call(Sink::new(sink));
    }
}

impl Routes {
    fn execute(&self, event: Inbound, sink: socket::Sink) {
        let sink = Sink::new(sink);

        match event {
            Inbound::AddLine(action)   => action.call(sink),
            Inbound::FindPulse(action) => action.call(sink),
            Inbound::TestPulse(action) => action.call(sink),
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
    pub fn send(&self, event: Outbound) {
        self.send_to(self.id(), event);
    }

    pub fn send_to(&self, id: &Id, event: Outbound) {
        // helper
        fn to_message<T>(name: &str, value: T) -> socket::Result<socket::MessageOut> where T: Serialize {
            socket::MessageOut::encoding_data(name.to_owned(), value)
        }

        // routes/out
        let message = match event {
            // story
            Outbound::ShowQueue(v)  => to_message("SHOW_QUEUE",  v),
            Outbound::ShowPrompt(v) => to_message("SHOW_PROMPT", v),
            Outbound::ShowThanks    => to_message("SHOW_THANKS", ()),
            Outbound::FindPulse   => to_message("CHECK_PULSE", ()),
            // shared
            Outbound::ShowInternalError => to_message("SHOW_INTERNAL_ERROR", ())
        };

        self.sink.send_to(id, message);
    }

    pub fn schedule(&self, event: Scheduled, ms: u64) {
        self.schedule_for(self.id(), event, ms)
    }

    pub fn schedule_for(&self, id: &Id, event: Scheduled, ms: u64) {
        let timeout = socket::Timeout::new(event as usize);
        self.sink.schedule_for(id, ms, timeout);
    }
}
