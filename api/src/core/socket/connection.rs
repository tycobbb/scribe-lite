use std::sync::Arc;
use core::socket;
use super::routes::Routes;
use super::sender::Sender;
use super::message::*;

// types
pub struct Connection {
    routes: Arc<Routes>,
    out:    Arc<Sender>
}

// impls
impl Connection {
    // init
    pub fn new(routes: Arc<Routes>, out: Arc<Sender>) -> Connection {
        Connection {
            routes: routes,
            out:    out
        }
    }
}

impl ws::Handler for Connection {
    fn on_message(&mut self, msg: ws::Message) -> ws::Result<()> {
        let decoded = msg
            .as_text()
            .map_err(socket::Error::SocketFailed)
            .and_then(MessageIn::decode);

        // send error if decode failed
        let incoming = match decoded {
            Ok(message) => message,
            Err(error)  => return Ok(self.out.send_error(error))
        };

        // send any outoing messages from the route
        let out = self.out.clone();
        self.routes.resolve(incoming, Box::new(move |outgoing: socket::Result<MessageOut>| {
            let encoded = outgoing.and_then(|message| {
                message.encode()
            });

            match encoded {
                Ok(outgoing) => out.send(outgoing),
                Err(error)   => out.send_error(error)
            };
        }));

        Ok(())
    }
}
