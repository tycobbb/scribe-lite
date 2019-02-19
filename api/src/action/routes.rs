use serde::Serialize;
use serde_json as json;
use core::action;
use core::socket;
use core::socket::routes;
use core::socket::{ EventIn, EventOut };
use super::event;
use super::event::Event::*;
use super::story;

// types
pub struct Routes;

// impls
impl socket::Routes for Routes {
    fn resolve<'a>(&self, msg: socket::MessageIn<'a>) -> socket::RouteOut {
        match msg.name {
            EventIn::StoryJoin    => self.resolve_event(story::Join.call()),
            EventIn::StoryAddLine => self.resolve_event(story::AddLine.call())
        }
    }
}

impl Routes {
    fn resolve_event(&self, event: event::Event) -> socket::RouteOut {
        match event {
            ShowPreviousLine(res) => socket::RouteOut::new(EventOut::ShowPreviousLine, self.encode_result(res)),
            ShowThanks(res)       => socket::RouteOut::new(EventOut::ShowThanks, self.encode_result(res))
        }
    }

    fn encode_result<T>(&self, result: action::Result<T>) -> socket::Result<json::Value> where T: Serialize {
        let value = result
            .map_err(socket::Error::ActionFailed)?;
        json::to_value(value)
            .map_err(socket::Error::EncodeFailed)
    }
}
