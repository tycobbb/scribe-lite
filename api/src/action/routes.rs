use serde::{ Serialize, Deserialize };
use core::socket::{ self, NameIn, NameOut };
use super::action::{ self, Action };
use super::event::*;
use super::story;

// types
pub struct Routes;

// impls
impl socket::Routes for Routes {
    fn resolve<'a>(&self, msg: socket::MessageIn<'a>) -> socket::Result<socket::MessageOut> {
        match msg.name {
            NameIn::JoinStory => self.to_action(&story::Join, msg),
            NameIn::AddLine   => self.to_action(&story::AddLine, msg)
        }
    }
}

impl Routes {
    fn to_action<'a, T>(&self,
        action: &Action<'a, Args=T>,
        msg:    socket::MessageIn<'a>
    ) -> socket::Result<socket::MessageOut> where T: Deserialize<'a> {
        let args = msg.decode_args()?;

        match action.call(args) {
            Event::ShowPrompt(res) => self.to_message(NameOut::ShowPrompt, res),
            Event::ShowThanks(res) => self.to_message(NameOut::ShowThanks, res)
        }
    }

    fn to_message<T>(&self,
        name:   NameOut,
        result: action::Result<T>
    ) -> socket::Result<socket::MessageOut> where T: Serialize {
        socket::MessageOut::encoding_result(name, result)
    }
}
