use super::message::MessageIn;
use super::sink::Sink;
use super::timeout::Timeout;
use crate::core::socket;

// -- types --
pub trait Routes {
    fn on_connect(&self, sink: Sink) -> socket::Result<()>;
    fn on_disconnect(&self, sink: Sink) -> socket::Result<()>;
    fn on_message<'a>(&self, msg: MessageIn<'a>, sink: Sink) -> socket::Result<()>;
    fn on_timeout<'a>(&self, timeout: Timeout, sink: Sink) -> socket::Result<()>;
}
