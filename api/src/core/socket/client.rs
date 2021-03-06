use crate::core::id::Id;
use std::cell::RefCell;
use std::collections::HashMap;
use std::rc::Rc;

// -- aliases --
pub type ClientById = HashMap<Id, Client>;

// -- types --
#[derive(Debug)]
pub struct Client(pub ws::Sender);

#[derive(Debug, Clone)]
pub struct Clients {
    clients: Rc<RefCell<ClientById>>,
}

// -- impls --
impl Client {
    pub fn id(&self) -> Id {
        Id(self.0.connection_id())
    }

    pub fn send(&self, message: ws::Message) {
        if let Err(error) = self.0.send(message) {
            error!("[socket] failed to send message ({})", error)
        }
    }

    pub fn schedule(&self, ms: u64, token: ws::util::Token) {
        if let Err(error) = self.0.timeout(ms, token) {
            error!("[socket] failed to schedule token={:?} ({})", token, error)
        }
    }
}

impl Clients {
    pub fn new(clients: Rc<RefCell<ClientById>>) -> Self {
        Clients { clients: clients }
    }

    // -- impls/commands
    pub fn send_to(&self, id: &Id, message: ws::Message) {
        self.with_client(id, |client| {
            client.send(message);
        })
    }

    pub fn schedule_for(&self, id: &Id, ms: u64, token: ws::util::Token) {
        self.with_client(id, |client| {
            client.schedule(ms, token);
        })
    }

    // -- impls/queries
    fn with_client<F>(&self, id: &Id, handler: F)
    where
        F: FnOnce(&Client),
    {
        let clients = self.clients.borrow();
        let client = guard!(clients.get(id), else {
            return error!("[socket] attempted to send to unknown client id={:?}", id)
        });

        handler(client);
    }
}
