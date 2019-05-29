use super::client::Clients;
use super::message::MessageOut;
use super::timeout::Timeout;
use crate::core::socket;
use crate::core::Id;
use serde_json as json;

// -- types --
#[derive(Debug, Clone)]
pub struct Sink {
    pub id: Id,
    clients: Clients,
}

// -- impls --
impl Sink {
    // -- impls/init
    pub fn new(id: Id, clients: Clients) -> Self {
        Sink {
            id: id,
            clients: clients,
        }
    }

    // -- impls/commands
    pub fn send_to(&self, id: &Id, outgoing: socket::Result<MessageOut>) {
        let mut encoded = outgoing.and_then(|message| message.encode());

        // if error, attempt to encode an internal error
        if let Err(error) = encoded {
            error!("[socket] internal error: {:?}", error);
            // don't hardcode this here
            encoded = MessageOut::new("SHOW_INTERNAL_ERROR", json::Value::Null).encode();
        }

        // extract message text, if possible
        let text = guard!(encoded, else |err| {
            return error!("[socket] failed to encode internal error: {:?}", err)
        });

        self.clients.send_to(id, ws::Message::text(text));
    }

    pub fn schedule_for(&self, id: &Id, ms: u64, event: Timeout) {
        self.clients.schedule_for(id, ms, event.token());
    }
}
