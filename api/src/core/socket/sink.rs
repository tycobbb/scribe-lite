use core::socket;
use super::event::NameOut;
use super::message::MessageOut;

// types
#[derive(Clone)]
pub struct Sink {
    out: ws::Sender
}

// impls
impl Sink {
    // init
    pub fn new(out: ws::Sender) -> Self {
        Sink {
            out: out
        }
    }

    // props
    pub fn id(&self) -> u32 {
        self.out.connection_id()
    }

    // commands
    pub fn send(&self, outgoing: socket::Result<MessageOut>) {
        let mut encoded = outgoing.and_then(|message| {
            message.encode()
        });

        // if error, attempt to encode an internal error
        if let Err(error) = encoded {
            error!("[socket] internal error: {:?}", error);
            encoded = MessageOut::named(NameOut::ShowInternalError).encode();
        }

        // extract message text, if possible
        let text = match encoded {
            Ok(text)   => text,
            Err(error) => return error!("[socket] failed to encode internal error: {:?}", error)
        };

        // send message
        let sent = self.out.send(ws::Message::text(text));

        if let Err(error) = sent {
            error!("[socket] failed to send message: {}", error)
        }
    }
}
