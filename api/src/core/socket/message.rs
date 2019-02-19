use serde::Serialize;
use serde_json as json;
use core::action as action;
use core::action::Action;
use socket;
use socket::event::{ EventIn, EventOut };

// types
#[derive(Deserialize, Debug)]
pub struct MessageIn<'a> {
    pub name: EventIn,
    #[serde(borrow)]
    pub params: &'a json::value::RawValue
}

#[derive(Serialize, Debug)]
pub struct MessageOut {
    pub name: EventOut,
    #[serde(flatten)]
    pub payload: Payload
}

#[derive(Serialize, Debug)]
#[serde(rename_all="lowercase")]
pub enum Payload {
    Data(json::Value),
    Errors(action::Errors)
}

// impls
impl<'a> MessageIn<'a> {
    // json
    pub fn decode(json: &'a str) -> socket::Result<MessageIn<'a>> {
        serde_json::from_str(json)
            .map_err(socket::Error::DecodeFailed)
    }
}

impl MessageOut {
    // init / factories
    pub fn new(name: EventOut, payload: Payload) -> MessageOut {
        MessageOut {
            name: name,
            payload: payload
        }
    }

    pub fn data(name: EventOut, value: json::Value) -> MessageOut {
        MessageOut::new(
            name,
            Payload::Data(value)
        )
    }

    pub fn errors(name: EventOut, errors: action::Errors) -> MessageOut {
        MessageOut::new(
            name,
            Payload::Errors(errors)
        )
    }

    // json
    pub fn encode(&self) -> socket::Result<String> {
        serde_json::to_string(&self)
            .map_err(socket::Error::EncodeFailed)
    }
}
