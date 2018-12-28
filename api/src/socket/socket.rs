use action;
use socket;
use socket::event::{ EventIn, EventOut };
use socket::message::{ MessageIn, MessageOut };
use story;

// constants
pub const HOST: &'static str = "127.0.0.1:8080";

// types
pub struct Socket {
    out: ws::Sender
}

// impls
impl Socket {
    // init
    pub fn new(out: ws::Sender) -> Socket {
        Socket {
            out: out
        }
    }

    // handle
    pub fn handle(&self, msg: ws::Message) -> ws::Result<()> {
        self.send_response(msg)
            .or_else(|error| {
                self.send_error(error)
            })
    }

    fn send(&self, text: String) -> ws::Result<()> {
        self.out.send(ws::Message::text(text))
    }

    fn send_response(&self, msg: ws::Message) -> socket::Result<()> {
        // try to decode message
        let incoming = msg
            .as_text()
            .map_err(socket::Error::SocketFailed)
            .and_then(MessageIn::decode)?;

        // if decoded, respond with an outgoing message
        let outgoing = match incoming.name {
            EventIn::StoryJoin    => incoming.resolve(&story::Join),
            EventIn::StoryAddLine => incoming.resolve(&story::AddLine)
        }?;

        // send the response
        self.send(outgoing)
            .map_err(socket::Error::SocketFailed)
    }

    fn send_error(&self, error: socket::Error) -> ws::Result<()> {
        print!("socket error: {:?}", error);

        let message = MessageOut::<()>::failure(
            EventOut::NetworkError,
            action::Errors::new(
                "Network Error"
            )
        );

        self.send(message.encode().unwrap())
    }
}
