use std::collections::HashMap;
use std::rc::Rc;
use std::cell::RefCell;
use super::routes::Routes;
use super::sink::Sink;
use super::connection::Connection;

// aliases
pub type ClientsById =
    HashMap<u32, ws::Sender>;

// types
pub struct Channel<R> where R: Routes + Clone {
    routes:  R,
    // TODO: this will panic when multi-threaded
    clients: Rc<RefCell<ClientsById>>
}

#[derive(Clone)]
pub struct Clients {
    clients: Rc<RefCell<ClientsById>>
}

// impls
impl<'a, R> Channel<R> where R: Routes + Clone {
    // init
    pub fn new(routes: R) -> Self {
        Channel {
            routes:  routes,
            clients: Rc::new(RefCell::new(ClientsById::new()))
        }
    }

    // commands
    pub fn join(&self, client: ws::Sender) -> u32 {
        let id = client.connection_id();
        self.clients.borrow_mut().insert(id, client);
        id
    }

    pub fn leave(&self, id: &u32) {
        self.clients.borrow_mut().remove(id);
    }
}

impl<R> ws::Factory for Channel<R> where R: Routes + Clone {
    type Handler = Connection<R>;

    fn connection_made(&mut self, client: ws::Sender) -> Self::Handler {
        let id = self.join(client);

        // create a connection to handle messages for this client
        Connection::new(
            self.routes.clone(),
            Sink::new(id, Clients::new(self.clients.clone()))
        )
    }

    fn connection_lost(&mut self, connection: Self::Handler) {
        self.leave(&connection.id());
    }
}

impl Clients {
    pub fn new(clients: Rc<RefCell<ClientsById>>) -> Self {
        Clients {
            clients: clients
        }
    }

    // commands
    pub fn send_to(&self, id: u32, message: ws::Message) {
        let clients = self.clients.borrow();
        let client  = match clients.get(&id) {
            Some(s) => s,
            None    => return error!("[socket] attempted to send to unknown client id={}", id)
        };

        // send message
        if let Err(error) = client.send(message) {
            error!("[socket] failed to send message: {}", error)
        }
    }
}
