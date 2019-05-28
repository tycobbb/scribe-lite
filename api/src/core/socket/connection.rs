use super::message::MessageIn;
use super::routes::Routes;
use super::sink::Sink;
use super::timeout::Timeout;
use crate::core::{socket, Id};

// -- types --
#[derive(Debug)]
pub struct Connection<R>
where
    R: Routes,
{
    routes: R,
    sink: Sink,
}

// -- impls --
impl<R> Connection<R>
where
    R: Routes,
{
    // -- impls/init --
    pub fn new(routes: R, sink: Sink) -> Connection<R> {
        Connection {
            routes: routes,
            sink: sink,
        }
    }

    // impls/queries
    pub fn id(&self) -> &Id {
        &self.sink.id
    }
}

impl<R> ws::Handler for Connection<R>
where
    R: Routes,
{
    fn on_open(&mut self, _: ws::Handshake) -> ws::Result<()> {
        self.routes.connect(self.sink.clone());
        Ok(())
    }

    fn on_message(&mut self, msg: ws::Message) -> ws::Result<()> {
        let decoded = msg
            .as_text()
            .map_err(socket::Error::SocketFailed)
            .and_then(MessageIn::decode);

        let handled =
            decoded.and_then(|message| self.routes.on_message(message, self.sink.clone()));

        if let Err(error) = handled {
            self.sink.send_to(self.id(), Err(error))
        }

        Ok(())
    }

    fn on_timeout(&mut self, token: ws::util::Token) -> ws::Result<()> {
        let handled = self
            .routes
            .on_timeout(Timeout::new(token.0), self.sink.clone());

        if let Err(error) = handled {
            self.sink.send_to(self.id(), Err(error))
        }

        Ok(())
    }

    fn on_close(&mut self, _: ws::CloseCode, _: &str) {
        self.routes.disconnect(self.sink.clone());
    }
}
