use serde::Serialize;
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
            NameIn::StoryJoin    => self.to_action(&story::Join),
            NameIn::StoryAddLine => self.to_action(&story::AddLine)
        }
    }
}

impl Routes {
    fn to_action(&self, action: &Action) -> socket::Result<socket::MessageOut> {
        match action.call() {
            Event::ShowPreviousLine(res) => self.to_message(NameOut::ShowPreviousLine, res),
            Event::ShowThanks(res)       => self.to_message(NameOut::ShowThanks, res)
        }
    }

    fn to_message<T>(&self, name: NameOut, result: action::Result<T>) -> socket::Result<socket::MessageOut> where T: Serialize {
        let encoded = result.map(|data| {
            json::to_value(data)
        });

        let message = match encoded {
            Ok(Ok(json))   => socket::MessageOut::data(name, json),
            Err(errors)    => socket::MessageOut::errors(name, errors),
            Ok(Err(error)) => return Err(socket::Error::EncodeFailed(error))
        };

        Ok(message)
    }
}
