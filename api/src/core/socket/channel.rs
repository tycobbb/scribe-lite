use super::routes::Routes;
use super::sink::Sink;
use super::connection::Connection;

// types
pub struct Channel<R> where R: Routes + Clone {
    routes: R
}

// impls
impl<R> Channel<R> where R: Routes + Clone {
    // init
    pub fn new(routes: R) -> Self {
        Channel {
            routes: routes
        }
    }
}

impl<R> ws::Factory for Channel<R> where R: Routes + Clone {
    type Handler = Connection<R>;

    fn connection_made(&mut self, out: ws::Sender) -> Self::Handler {
        Connection::new(
            self.routes.clone(),
            Sink::new(out)
        )
    }
}
