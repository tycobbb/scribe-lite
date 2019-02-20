use serde_json as json;
use core::action;
use core::socket;
use super::event::*;
use super::message::*;

// types
pub trait Routes {
    fn resolve<'a>(&self, msg: MessageIn<'a>) -> socket::Result<MessageOut>;
}
