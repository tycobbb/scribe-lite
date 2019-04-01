use serde::{ Serialize, Deserialize };
use crate::core::Id;
use crate::core::socket;
use super::action::Action;
use super::event::{ Outbound, Scheduled };
use super::story;

// types
#[derive(Clone)]
pub struct Routes;

#[derive(Clone)]
pub struct Sink {
    sink: socket::Sink
}

// impls/inbound
impl socket::Routes for Routes {
    // commands
    fn connect(&self, sink: socket::Sink) {
        story::Join.call(Sink::new(sink));
    }

    fn on_message<'a>(&self, msg: socket::MessageIn<'a>, sink: socket::Sink) -> socket::Result<()> {
        use bind_action_from_message as route;

        match msg.name {
            "ADD_LINE" => route::<story::AddLine>(msg, sink),
            _          => return Ok(error!("[routes] received unknown msg={:?}", msg))
        }
    }

    fn on_timeout(&self, timeout: socket::Timeout, sink: socket::Sink) -> socket::Result<()> {
        use bind_action_from_empty as route;

        let scheduled = match Scheduled::from_raw(timeout.value()) {
            Some(scheduled) => scheduled,
            None            => return Ok(error!("[routes] received unknown timeout={:?}", timeout))
        };

        match scheduled {
            Scheduled::FindPulse => route::<story::FindPulse>(sink),
            Scheduled::TestPulse => route::<story::TestPulse>(sink)
        }
    }

    fn disconnect(&self, sink: socket::Sink) {
        story::Leave.call(Sink::new(sink));
    }
}

// impls/outbound
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
        use bind_message_from_data as route;

        let message = match event {
            Outbound::ShowQueue(d)      => route("SHOW_QUEUE", d),
            Outbound::ShowPrompt(d)     => route("SHOW_PROMPT", d),
            Outbound::ShowThanks        => route("SHOW_THANKS", ()),
            Outbound::CheckPulse        => route("CHECK_PULSE", ()),
            Outbound::ShowInternalError => route("SHOW_INTERNAL_ERROR", ())
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

// impls/binding
fn bind_action<'a, A>(args: A::Args, sink: socket::Sink) where A: Action {
    let action = A::new(args);
    action.call(Sink::new(sink));
}

fn bind_action_from_message<'a, A>(
    msg:  socket::MessageIn<'a>,
    sink: socket::Sink
) -> socket::Result<()> where A: Action, A::Args: Deserialize<'a> {
    msg.decode_args().map(|args| bind_action::<A>(args, sink))
}

fn bind_action_from_empty<'a, A>(
    sink: socket::Sink
) -> socket::Result<()> where A: Action<Args=()> {
    bind_action::<A>((), sink);
    Ok(())
}

fn bind_message_from_data<T>(
    name:  &str,
    value: T
) -> socket::Result<socket::MessageOut> where T: Serialize {
    socket::MessageOut::encoding_data(name.to_owned(), value)
}
