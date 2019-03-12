use std::rc::Rc;
use std::cell::RefCell;
use std::collections::HashMap;
use core::id::Id;

// aliases
pub type ClientById =
    HashMap<Id, Client>;

// types
#[derive(Debug)]
pub struct Client(
    pub ws::Sender
);

#[derive(Debug, Clone)]
pub struct Clients {
    clients: Rc<RefCell<ClientById>>
}

// impls
impl Client {
    pub fn id(&self) -> Id {
        Id(self.0.connection_id())
    }

    pub fn send(&self, message: ws::Message) {
        if let Err(error) = self.0.send(message) {
            error!("[socket] failed to send message: {}", error)
        }
    }
}

impl Clients {
    pub fn new(clients: Rc<RefCell<ClientById>>) -> Self {
        Clients {
            clients: clients
        }
    }

    // commands
    pub fn send_to(&self, id: &Id, message: ws::Message) {
        let clients = self.clients.borrow();

        match clients.get(id) {
            Some(client) => client.send(message),
            None         => return error!("[socket] attempted to send to unknown client id={:?}", id)
        };
    }
}
