use serde_json as json;
use core::{ socket, Id };
use super::routes::Routes;
use super::sink::Sink;
use super::event::{ NameIn, Scheduled };
use super::message::MessageIn;

// types
#[derive(Debug)]
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

    // props
    pub fn id(&self) -> &Id {
        &self.sink.id
    }

    // commands
    fn resolve(&self, incoming: MessageIn) {
        self.routes.resolve(incoming, self.sink.clone())
    }

    fn resolve_named(&self, name: NameIn) {
        // TODO: can we avoid RawValue? maybe by using resource-based routing
        // to split message from event/resource name:
        // https://github.com/housleyjk/ws-rs/blob/master/examples/router.rs
        let value = json::value::RawValue::from_string("null".to_owned()).unwrap();
        self.resolve(MessageIn::new(name, &value));
    }
}

impl<R> ws::Handler for Connection<R> where R: Routes {
    fn on_open(&mut self, _: ws::Handshake) -> ws::Result<()> {
        self.resolve_named(NameIn::JoinStory);
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
            Err(error)  => return Ok(self.sink.send_to(self.id(), Err(error)))
        };

        self.resolve(incoming);

        Ok(())
    }

    fn on_timeout(&mut self, token: ws::util::Token) -> ws::Result<()> {
        match Scheduled::new(token) {
            Scheduled::CHECK_PULSE_1 =>
                self.resolve_named(NameIn::CheckPulse1),
            _ => error!("[socket] received unknown timeout token={:?}", token)
        };

        Ok(())
    }

    fn on_close(&mut self, _: ws::CloseCode, _: &str) {
        self.resolve_named(NameIn::LeaveStory);
    }
}
