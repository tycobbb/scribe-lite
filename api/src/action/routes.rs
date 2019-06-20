use super::action::Action;
use super::event::{Outbound, Scheduled};
use super::story;
use crate::core::socket;
use crate::core::Id;
use serde::{Deserialize, Serialize};

// -- types --
#[derive(Clone)]
pub struct Routes;

#[derive(Clone)]
pub struct Sink {
    sink: socket::Sink,
}

// -- impls --
// -- impls/inbound
impl socket::Routes for Routes {
    // -- impls/commands
    fn on_connect(&self, sink: socket::Sink) -> socket::Result<()> {
        use bind_action_from_empty as bind;
        bind::<story::Join>(sink)
    }

    fn on_message<'a>(&self, msg: socket::MessageIn<'a>, sink: socket::Sink) -> socket::Result<()> {
        use bind_action_from_message as bind;
        match msg.name {
            "ADD_LINE" => bind::<story::AddLine>(msg, sink),
            "SAVE_PULSE" => bind::<story::SavePulse>(msg, sink),
            _ => return Ok(error!("[routes] received unknown msg={:?}", msg)),
        }
    }

    fn on_timeout(&self, timeout: socket::Timeout, sink: socket::Sink) -> socket::Result<()> {
        let scheduled = guard!(Scheduled::from_raw(timeout.value()), else {
            return Ok(error!("[routes] received unknown timeout={:?}", timeout))
        });

        use bind_action_from_empty as bind;
        match scheduled {
            Scheduled::FindPulse => bind::<story::FindPulse>(sink),
            Scheduled::TestPulse => bind::<story::TestPulse>(sink),
        }
    }

    fn on_disconnect(&self, sink: socket::Sink) -> socket::Result<()> {
        use bind_action_from_empty as bind;
        bind::<story::Leave>(sink)
    }
}

// -- impls/outbound
impl Sink {
    // -- impls/init --
    pub fn new(sink: socket::Sink) -> Self {
        Sink { sink: sink }
    }

    // -- impls/queries
    pub fn id(&self) -> &Id {
        &self.sink.id
    }

    // -- impls/commands
    pub fn send(&self, event: Outbound) {
        self.send_to(self.id(), event);
    }

    pub fn send_to(&self, id: &Id, event: Outbound) {
        use bind_message_from_data as bind;
        let message = match event {
            Outbound::ShowQueue(d) => bind("SHOW_QUEUE", d),
            Outbound::ShowPrompt(d) => bind("SHOW_PROMPT", d),
            Outbound::ShowThanks => bind("SHOW_THANKS", ()),
            Outbound::FindPulse => bind("FIND_PULSE", ()),
            Outbound::ShowDisconnected => bind("SHOW_DISCONNECTED", ()),
            Outbound::ShowInternalError(d) => bind("SHOW_INTERNAL_ERROR", d),
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

// -- impls/binding
fn bind_action<'a, A>(args: A::Args, sink: socket::Sink)
where
    A: Action,
{
    let action = A::new(args);
    action.call(Sink::new(sink));
}

fn bind_action_from_message<'a, A>(
    msg: socket::MessageIn<'a>,
    sink: socket::Sink,
) -> socket::Result<()>
where
    A: Action,
    A::Args: Deserialize<'a>,
{
    msg.decode_args().map(|args| bind_action::<A>(args, sink))
}

fn bind_action_from_empty<'a, A>(sink: socket::Sink) -> socket::Result<()>
where
    A: Action<Args = ()>,
{
    bind_action::<A>((), sink);
    Ok(())
}

fn bind_message_from_data<T>(name: &str, value: T) -> socket::Result<socket::MessageOut>
where
    T: Serialize,
{
    socket::MessageOut::encoding_data(name.to_owned(), value)
}
