use serde_json as json;
use core::action;

// result type for the socket module
pub type Result<T> =
    std::result::Result<T, Error>;

// error type for the socket module
#[derive(Debug)]
pub enum Error {
    ActionFailed(action::Errors),
    SocketFailed(ws::Error),
    DecodeFailed(json::Error),
    EncodeFailed(json::Error),
}
