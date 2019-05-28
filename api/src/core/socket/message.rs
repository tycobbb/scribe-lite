use crate::core::socket;
use serde::{Deserialize, Serialize};
use serde_derive::{Deserialize, Serialize};
use serde_json as json;

// -- types --
#[derive(Deserialize, Debug)]
pub struct MessageIn<'a> {
    pub name: &'a str,
    #[serde(borrow)]
    pub args: &'a json::value::RawValue,
}

#[derive(Serialize, Debug)]
pub struct MessageOut {
    pub name: String,
    pub data: json::Value,
}

// -- impls --
impl<'a> MessageIn<'a> {
    // -- impls/json
    pub fn decode(json_str: &'a str) -> socket::Result<MessageIn> {
        json::from_str(json_str).map_err(socket::Error::DecodeFailed)
    }

    pub fn decode_args<T>(&self) -> socket::Result<T>
    where
        T: Deserialize<'a>,
    {
        json::from_str(self.args.get()).map_err(socket::Error::DecodeFailed)
    }
}

impl MessageOut {
    // -- init/factories
    pub fn new<T>(name: T, data: json::Value) -> MessageOut
    where
        T: Into<String>,
    {
        MessageOut {
            name: name.into(),
            data: data,
        }
    }

    // -- impls/json
    pub fn encode(&self) -> socket::Result<String> {
        json::to_string(&self).map_err(socket::Error::EncodeFailed)
    }

    pub fn encoding_data<T>(name: String, value: T) -> socket::Result<MessageOut>
    where
        T: Serialize,
    {
        json::to_value(value)
            .map_err(socket::Error::EncodeFailed)
            .map(|data| MessageOut::new(name, data))
    }
}
