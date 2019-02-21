use serde::{ Serialize, Deserialize };
use serde_json as json;
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
        match action.call(msg.decode_args()?) {
            Event::ShowPrompt(res) => self.to_message(NameOut::ShowPrompt, res),
            Event::ShowThanks(res) => self.to_message(NameOut::ShowThanks, res)
        }
    }

    fn to_message<T>(&self,
        name:   NameOut,
        result: action::Result<T>
    ) -> socket::Result<socket::MessageOut> where T: Serialize {
        let encoded = result.map(|data| {
            json::to_value(data)
        });

        let msg = match encoded {
            Ok(Ok(json))   => socket::MessageOut::data(name, json),
            Err(errors)    => socket::MessageOut::errors(name, errors),
            Ok(Err(error)) => return Err(socket::Error::EncodeFailed(error))
        };

        Ok(msg)
    }
}
