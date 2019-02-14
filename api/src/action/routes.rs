use serde::Serialize;
use serde_json as json;
use core::action;
use core::socket;
use core::socket::{ EventIn, MessageIn };
use super::event;
use super::event::Event::*;
use super::story;

// types
pub struct Routes;

#[derive(Serialize, Debug)]
pub struct MessageOut<'a> {
    pub name: &'a str,
    #[serde(flatten)]
    pub payload: Payload<'a>
}

#[derive(Serialize, Debug)]
#[serde(rename_all="lowercase")]
pub enum Payload<'a> {
    Data(json::Value),
    Errors(action::Errors<'a>)
}

// impls
impl socket::Routes for Routes {
    fn resolve(&self, msg: MessageIn) -> socket::Result<String> {
        let event = story::Join.call();
        let messsage = MessageOut::from_event(event);

        return Ok("foo".to_owned())
        // match msg.name {
        //     EventIn::StoryJoin    => msg.resolve(&story::Join),
        //     EventIn::StoryAddLine => msg.resolve(&story::AddLine)
        // }
    }
}

impl<'a> MessageOut<'a> {
    fn new(name: &'a str, payload: Payload<'a>) -> MessageOut<'a> {
        MessageOut {
            name,
            payload
        }
    }

    fn from_event(event: event::Event<'a>) -> MessageOut<'a> {
        match event {
            ShowPreviousLine(res) => MessageOut::new("STORY.SHOW_PREVIOUS_LINE", Payload::from_result(res)),
            ShowThanks(res)       => MessageOut::new("STORY.SHOW_THANKS", Payload::from_result(res))
        }
    }
}

impl<'a> Payload<'a> {
    fn from_result<T>(result: action::Result<'a, T>) -> Payload<'a> where T: Serialize {
        let result = result.and_then(Payload::encode_value);

        match result {
            Ok(v)  => Payload::Data(v),
            Err(e) => Payload::Errors(e)
        }
    }

    fn encode_value<T>(value: T) -> action::Result<'a, json::Value> where T: Serialize {
        json::to_value(value).map_err(Payload::encoding_error)
    }

    fn encoding_error(_: json::Error) -> action::Errors<'a> {
        action::Errors {
            messages: "Encoding failed."
        }
    }
}
