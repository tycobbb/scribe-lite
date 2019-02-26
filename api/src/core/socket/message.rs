use serde::{ Serialize, Deserialize };
use serde_json as json;
use core::{ errors, socket };
use super::event::{ NameIn, NameOut };

// types
#[derive(Deserialize, Debug)]
pub struct MessageIn<'a> {
    pub name: NameIn,
    #[serde(borrow)]
    pub args: &'a json::value::RawValue
}

#[derive(Serialize, Debug)]
pub struct MessageOut {
    pub name: NameOut,
    #[serde(flatten)]
    pub payload: Payload
}

#[derive(Serialize, Debug)]
#[serde(rename_all="lowercase")]
pub enum Payload {
    Data(json::Value),
    Errors(errors::Errors)
}

// impls
impl<'a> MessageIn<'a> {
    // json
    pub fn decode(json_str: &'a str) -> socket::Result<MessageIn> {
        json::from_str(json_str)
            .map_err(socket::Error::DecodeFailed)
    }

    pub fn decode_args<T>(&self) -> socket::Result<T> where T: Deserialize<'a> {
        json::from_str(self.args.get())
            .map_err(socket::Error::DecodeFailed)
    }
}

impl MessageOut {
    // init / factories
    pub fn new(name: NameOut, payload: Payload) -> MessageOut {
        MessageOut {
            name: name,
            payload: payload
        }
    }

    pub fn data(name: NameOut, value: json::Value) -> MessageOut {
        MessageOut::new(
            name,
            Payload::Data(value)
        )
    }

    pub fn errors(name: NameOut, errors: errors::Errors) -> MessageOut {
        MessageOut::new(
            name,
            Payload::Errors(errors)
        )
    }

    // json
    pub fn encode(&self) -> socket::Result<String> {
        json::to_string(&self)
            .map_err(socket::Error::EncodeFailed)
    }

    pub fn encoding_result<T>(
        name:   NameOut,
        result: Result<T, errors::Errors>
    ) -> socket::Result<MessageOut> where T: Serialize {
        let encoded = result.map(|data| {
            json::to_value(data)
        });

        let msg = match encoded {
            Ok(Ok(json))   => MessageOut::data(name, json),
            Err(errors)    => MessageOut::errors(name, errors),
            Ok(Err(error)) => return Err(socket::Error::EncodeFailed(error))
        };

        Ok(msg)
    }
}
