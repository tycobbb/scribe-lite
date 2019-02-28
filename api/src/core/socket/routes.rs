use core::sink;
use core::socket;
use super::message::*;

// types
pub type Sink =
    sink::Sink<socket::Result<MessageOut>>;

pub trait Routes {
    // https://github.com/rust-lang/rust/issues/41517
    fn resolve<'a>(&self, msg: MessageIn<'a>, sink: Sink);
}
