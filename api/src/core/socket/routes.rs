use super::sink::Sink;
use super::message::MessageIn;

// types
pub trait Routes {
    // https://github.com/rust-lang/rust/issues/41517
    fn resolve<'a>(&self, msg: MessageIn<'a>, sink: Sink);
}
