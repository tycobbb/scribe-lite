use core::socket;
use super::event::NameOut;
use super::message::MessageOut;

// types
pub struct Channel {
    out: ws::Sender,
}

// impls
impl Channel {
    // init
    pub fn new(out: ws::Sender) -> Channel {
        Channel {
            out: out
        }
    }

    // commands
    pub fn send(&self, text: String) {
        let result = self.out.send(ws::Message::text(text));

        if let Err(error) = result {
            error!("[socket] failed to send message: {}", error)
        }
    }

    pub fn send_error(&self, error: socket::Error) {
        error!("[socket] internal error: {:?}", error);

        let message = MessageOut::named(NameOut::ShowInternalError);

        match message.encode() {
            Ok(text)   => self.send(text),
            Err(error) => error!("[socket] failed to encode internal error: {:?}", error)
        };
    }
}
