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
            NameIn::StoryJoin    => self.resolve_event(story::Join.call()),
            NameIn::StoryAddLine => self.resolve_event(story::AddLine.call())
        }
    }
}

impl Routes {
    fn resolve_event(&self, event: Event) -> socket::Result<socket::MessageOut> {
        match event {
            Event::ShowPreviousLine(res) => self.resolve_event_result(NameOut::ShowPreviousLine, res),
            Event::ShowThanks(res)       => self.resolve_event_result(NameOut::ShowThanks, res)
        }
    }

    fn resolve_event_result<T>(&self, name: NameOut, result: action::Result<T>) -> socket::Result<socket::MessageOut> where T: Serialize {
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
