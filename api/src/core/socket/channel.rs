use core::errors;
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
            println!("[socket] send error: {}", error)
        }
    }

    pub fn send_error(&self, error: socket::Error) {
        println!("socket error: {:?}", error);

        let message = MessageOut::errors(
            NameOut::NetworkError,
            errors::Errors::new(
                "Network Error"
            )
        );

        self.send(message.encode().unwrap());
    }
}
