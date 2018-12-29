// result type for the socket module
pub type Result<T> =
    std::result::Result<T, Error>;

// error type for the socket module
#[derive(Debug)]
pub enum Error {
    SocketFailed(ws::Error),
    DecodeFailed(serde_json::Error),
    EncodeFailed(serde_json::Error),
}
