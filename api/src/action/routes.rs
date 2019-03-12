use serde::{ Serialize, Deserialize };
use core::Id;
use core::socket::{ self, NameIn, NameOut };
use super::action::Action;
use super::event::*;
use super::story;

// types
#[derive(Clone)]
pub struct Routes;

#[derive(Clone)]
pub struct Sink {
    sink: socket::Sink
}

// impls
impl socket::Routes for Routes {
    fn resolve<'a>(&self, msg: socket::MessageIn<'a>, sink: socket::Sink) {
        // helper
        fn to_action<'a, A>(
            action: &Action<'a, Args=A>,
            msg:    socket::MessageIn<'a>,
            sink:   socket::Sink
        ) where A: Deserialize<'a> {
            let args = match msg.decode_args() {
                Ok(args)   => args,
                Err(error) => return sink.send(Err(error))
            };

            action.call(args, Sink::new(sink));
        }

        // routes/in
        match msg.name {
            NameIn::JoinStory  => to_action(&story::Join, msg, sink),
            NameIn::AddLine    => to_action(&story::AddLine, msg, sink),
            NameIn::LeaveStory => to_action(&story::Leave, msg, sink)
        }
    }
}

impl Sink {
    // init
    pub fn new(sink: socket::Sink) -> Self {
        Sink {
            sink: sink
        }
    }

    // props
    pub fn id(&self) -> &Id {
        &self.sink.id
    }

    // commands
    pub fn send(&self, event: Event) {
        self.send_to(self.id(), event);
    }

    pub fn send_to(&self, id: &Id, event: Event) {
        // helper
        fn to_message<T>(name: NameOut, value: T) -> socket::Result<socket::MessageOut> where T: Serialize {
            socket::MessageOut::encoding_data(name, value)
        }

        // routes/out
        let message = match event {
            Event::ShowQueue(v)        => to_message(NameOut::ShowQueue, v),
            Event::ShowPrompt(v)       => to_message(NameOut::ShowPrompt, v),
            Event::ShowThanks          => to_message(NameOut::ShowThanks, ()),
            Event::ShowInternalError   => to_message(NameOut::ShowInternalError, ())
        };

        self.sink.send_to(id, message);
    }
}
