use std::rc::Rc;
use core::socket;
use super::routes::Routes;
use super::channel::Channel;
use super::message::*;

// types
pub struct Connection {
    routes:  Rc<Routes>,
    channel: Rc<Channel>
}

// impls
impl Connection {
    // init
    pub fn new(routes: Rc<Routes>, channel: Rc<Channel>) -> Connection {
        Connection {
            routes:  routes,
            channel: channel
        }
    }

    // handle
    pub fn handle(self, msg: ws::Message) {
        let decoded = msg
            .as_text()
            .map_err(socket::Error::SocketFailed)
            .and_then(MessageIn::decode);

        // send error if decode failed
        let incoming = match decoded {
            Ok(message) => message,
            Err(error)  => return self.channel.send_error(error)
        };

        // send any outoing messages from the route
        let channel = self.channel.clone();
        self.routes.resolve(incoming, Box::new(move |outgoing: socket::Result<MessageOut>| {
            let encoded = outgoing.and_then(|message| {
                message.encode()
            });

            match encoded {
                Ok(outgoing) => channel.send(outgoing),
                Err(error)   => channel.send_error(error)
            };
        }));
    }
}
