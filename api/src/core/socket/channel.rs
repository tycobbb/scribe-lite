use super::client::{Client, ClientById, Clients};
use super::connection::Connection;
use super::routes::Routes;
use super::sink::Sink;
use crate::core::Id;
use std::cell::RefCell;
use std::rc::Rc;

// -- types --
pub struct Channel<R>
where
    R: Routes + Clone,
{
    routes: R,
    // TODO: this will panic when multi-threaded
    clients: Rc<RefCell<ClientById>>,
}

// -- impls --
impl<'a, R> Channel<R>
where
    R: Routes + Clone,
{
    // -- impls/init --
    pub fn new(routes: R) -> Self {
        Channel {
            routes: routes,
            clients: Rc::new(RefCell::new(ClientById::new())),
        }
    }

    // -- impls/commands
    pub fn join(&self, sender: ws::Sender) -> Id {
        let client = Client(sender);
        let id = client.id();
        self.clients.borrow_mut().insert(id.clone(), client);
        id
    }

    pub fn leave(&self, id: &Id) {
        self.clients.borrow_mut().remove(id);
    }
}

impl<R> ws::Factory for Channel<R>
where
    R: Routes + Clone,
{
    type Handler = Connection<R>;

    fn connection_made(&mut self, sender: ws::Sender) -> Self::Handler {
        let id = self.join(sender);
        // create sink for sending client messages
        let sink = Sink::new(id, Clients::new(self.clients.clone()));
        // create a connection to the lifecycle for this client
        Connection::new(self.routes.clone(), sink)
    }

    fn connection_lost(&mut self, connection: Self::Handler) {
        self.leave(&connection.id());
    }
}
