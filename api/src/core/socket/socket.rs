use serde_json as json;
use core::errors;
use core::socket;
use super::routes::Routes;
use super::event::NameOut;
use super::message::*;

// types
pub struct Socket<'a, T> where T: Routes {
    out:    ws::Sender,
    routes: &'a T
}

// impls
impl<'a, T> Socket<'a, T> where T: Routes {
    // init
    pub fn new(out: ws::Sender, routes: &'a T) -> Socket<'a, T> {
        Socket {
            out:    out,
            routes: routes
        }
    }

    // handle
    pub fn handle(&self, msg: ws::Message) -> ws::Result<()> {
        self.send_response(msg)
            .or_else(|error| {
                self.send_error(error)
            })
    }

    fn send_response(&self, msg: ws::Message) -> socket::Result<()> {
        // try to decode message
        let incoming = msg
            .as_text()
            .map_err(socket::Error::SocketFailed)
            .and_then(MessageIn::decode)?;

        // if decoded, respond with an outgoing message
        let outgoing = self.routes
            .resolve(incoming)?
            .encode()?;

        // send the response
        self.send(outgoing)
            .map_err(socket::Error::SocketFailed)
    }

    fn send_error(&self, error: socket::Error) -> ws::Result<()> {
        println!("socket error: {:?}", error);

        let message = MessageOut::errors(
            NameOut::NetworkError,
            errors::Errors::new(
                "Network Error"
            )
        );

        self.send(message.encode().unwrap())
    }

    fn send(&self, text: String) -> ws::Result<()> {
        self.out.send(ws::Message::text(text))
    }
}
