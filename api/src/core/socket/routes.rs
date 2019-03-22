use crate::core::socket;
use super::sink::Sink;
use super::message::MessageIn;
use super::event::Timeout;

// types
pub trait Routes {
    // commands
    fn connect(&self, sink: Sink);
    fn disconnect(&self, sink: Sink);

    // events
    fn on_message<'a>(&self, msg: MessageIn<'a>, sink: Sink) -> socket::Result<()>;
    fn on_timeout<'a>(&self, timeout: Timeout, sink: Sink) -> socket::Result<()>;
}
