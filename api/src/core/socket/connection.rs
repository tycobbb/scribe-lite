use serde_json as json;
use core::socket;
use super::routes::Routes;
use super::sink::Sink;
use super::event::NameIn;
use super::message::MessageIn;

// types
pub struct Connection<R> where R: Routes {
    routes: R,
    sink:   Sink
}

// impls
impl<R> Connection<R> where R: Routes {
    // init
    pub fn new(routes: R, sink: Sink) -> Connection<R> {
        Connection {
            routes: routes,
            sink:   sink
        }
    }

    // commands
    fn on_incoming(&self, incoming: MessageIn) {
        let sink = self.sink.clone();

        // send any outoing messages from the route
        self.routes.resolve(incoming, sink)
    }
}

impl<R> ws::Handler for Connection<R> where R: Routes {
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
            Err(error)  => return Ok(self.sink.send(Err(error))
        };

        self.on_incoming(incoming);

        Ok(())
    }

    fn on_close(&mut self, _: ws::CloseCode, _: &str) {
        // TODO: see on_open
        if let Ok(value) = json::value::RawValue::from_string("null".to_owned()) {
            self.on_incoming(MessageIn::new(NameIn::LeaveStory, &value));
        }
    }
}
