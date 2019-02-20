use core::socket;
use super::message::*;

// types
pub trait Routes {
    fn resolve<'a>(&self, msg: MessageIn<'a>) -> socket::Result<MessageOut>;
}
