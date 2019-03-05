use std::sync::Arc;
use serde_json as json;
use core::socket;
use super::routes::Routes;
use super::sender::Sender;
use super::event::NameIn;
use super::message::{ MessageIn, MessageOut };

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

    // commands
    fn on_incoming(&self, incoming: MessageIn) {
        let out = self.out.clone();

        // send any outoing messages from the route
        self.routes.resolve(incoming, Box::new(move |outgoing: socket::Result<MessageOut>| {
            let encoded = outgoing.and_then(|message| {
                message.encode()
            });

            match encoded {
                Ok(outgoing) => out.send(outgoing),
                Err(error)   => out.send_error(error)
            };
        }));
    }
}

impl ws::Handler for Connection {
    fn on_open(&mut self, _: ws::Handshake) -> ws::Result<()> {
        // TODO: can we avoid RawValue? maybe by using resource-based routing
        // to split message from event/resource name:
        // https://github.com/housleyjk/ws-rs/blob/master/examples/router.rs
        if let Ok(value) = json::value::RawValue::from_string("null".to_owned()) {
            self.on_incoming(MessageIn::new(NameIn::JoinStory, &value));
        }

        Ok(())
    }

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

        self.on_incoming(incoming);

        Ok(())
    }
}
