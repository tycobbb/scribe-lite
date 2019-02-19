use serde_json as json;
use core::action;
use core::socket;
use super::event::*;
use super::message::*;

// types
pub trait Routes {
    fn resolve<'a>(&self, msg: MessageIn<'a>) -> RouteOut;
}

#[derive(Debug)]
pub struct RouteOut {
    pub name:   EventOut,
    pub result: socket::Result<json::Value>
}

// impls
impl RouteOut {
    pub fn new(name: EventOut, result: socket::Result<json::Value>) -> RouteOut {
        RouteOut {
            name:   name,
            result: result
        }
    }
}
