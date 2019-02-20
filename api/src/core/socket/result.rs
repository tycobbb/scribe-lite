use serde_json as json;

// result type for the socket module
pub type Result<T> =
    std::result::Result<T, Error>;

// error type for the socket module
#[derive(Debug)]
pub enum Error {
    SocketFailed(ws::Error),
    DecodeFailed(json::Error),
    EncodeFailed(json::Error),
}
