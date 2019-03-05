use std::sync::Arc;
use super::routes::Routes;
use super::sender::Sender;
use super::connection::Connection;

// types
pub struct Channel {
    routes: Arc<Routes>
}

// impls
impl Channel {
    // init
    pub fn new(routes: Arc<Routes>) -> Channel {
        Channel {
            routes: routes
        }
    }
}

impl ws::Factory for Channel {
    type Handler = Connection;

    fn connection_made(&mut self, out: ws::Sender) -> Connection {
        Connection::new(
            self.routes.clone(),
            Arc::new(Sender::new(out))
        )
    }
}
