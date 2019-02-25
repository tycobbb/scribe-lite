use serde::Deserialize;
use core::socket::{ self, NameIn, NameOut };
use super::action::Action;
use super::event::*;
use super::story;

// types
pub struct Routes;

// impls
impl socket::Routes for Routes {
    fn resolve<'a>(&self, msg: socket::MessageIn<'a>, sink: socket::Sink) {
        match msg.name {
            NameIn::JoinStory => self.to_action(&story::Join, msg, sink),
            NameIn::AddLine   => self.to_action(&story::AddLine, msg, sink)
        }
    }
}

impl Routes {
    fn to_action<'a, A>(&self,
        action: &Action<'a, Args=A>,
        msg:    socket::MessageIn<'a>,
        sink:   socket::Sink
    ) where A: Deserialize<'a> {
        let args = match msg.decode_args() {
            Ok(args)   => args,
            Err(error) => return sink(Err(error))
        };

        action.call(args, Box::new(move |event: Event| {
            sink(event.into_message())
        }));
    }
}

impl Event {
    fn into_message(self) -> socket::Result<socket::MessageOut> {
        use socket::MessageOut;

        match self {
            Event::ShowPrompt(res) => MessageOut::encoding_result(NameOut::ShowPrompt, res),
            Event::ShowThanks(res) => MessageOut::encoding_result(NameOut::ShowThanks, res)
        }
    }
}

