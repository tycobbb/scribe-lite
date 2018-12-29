use serde::Serialize;
use core::action as action;
use core::action::Action;
use socket;
use socket::event::{ EventIn, EventOut };

// types
#[derive(Deserialize, Debug)]
pub struct MessageIn<'a> {
    pub name: EventIn,
    #[serde(borrow)]
    pub params: &'a serde_json::value::RawValue
}

#[derive(Serialize, Debug)]
pub struct MessageOut<'a, T> where T: Serialize {
    pub name: EventOut,
    #[serde(flatten)]
    pub payload: Payload<'a, T>
}

#[derive(Serialize, Debug)]
#[serde(rename_all="lowercase")]
pub enum Payload<'a, T> where T: Serialize {
    Data(T),
    Errors(action::Errors<'a>)
}

// impls
impl<'a> MessageIn<'a> {
    // action resolution
    pub fn resolve<T>(&self, action: &Action<T>) -> socket::Result<String> where T: Serialize {
        let payload  = Payload::from(action.call());
        let outgoing = MessageOut::new(
            self.name.to_event_out(),
            payload
        );

        outgoing.encode()
    }

    // json
    pub fn decode(json: &'a str) -> socket::Result<MessageIn<'a>> {
        serde_json::from_str(json)
            .map_err(socket::Error::DecodeFailed)
    }
}

impl<'a, T> MessageOut<'a, T> where T: Serialize {
    // init / factories
    pub fn new(name: EventOut, payload: Payload<'a, T>) -> MessageOut<'a, T> {
        MessageOut {
            name: name,
            payload: payload
        }
    }

    pub fn failure(name: EventOut, errors: action::Errors<'a>) -> MessageOut<'a, T> {
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

impl<'a, T> From<action::Result<'a, T>> for Payload<'a, T> where T: Serialize {
    fn from(result: action::Result<'a, T>) -> Payload<'a, T> {
        match result {
            Ok(data)    => Payload::Data(data),
            Err(errors) => Payload::Errors(errors)
        }
    }
}
