use core::socket;
use super::event::NameOut;
use super::message::MessageOut;
use super::channel::Clients;

// types
#[derive(Clone)]
pub struct Sink {
    pub id:  u32,
    clients: Clients
}

// impls
impl Sink {
    // init
    pub fn new(id: u32, clients: Clients) -> Self {
        Sink {
            id:      id,
            clients: clients
        }
    }

    // commands
    pub fn send(&self, outgoing: socket::Result<MessageOut>) {
        self.send_to(self.id, outgoing);
    }

    pub fn send_to(&self, id: u32, outgoing: socket::Result<MessageOut>) {
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

        self.clients.send_to(id, ws::Message::text(text));
    }
}
