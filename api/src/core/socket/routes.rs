use socket;
use socket::message::MessageIn;

// types
pub trait Routes {
    fn resolve(&self, msg: MessageIn) -> socket::Result<String>;
}
