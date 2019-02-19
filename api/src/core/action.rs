use serde::Serialize;

// types
// a command type that produces a serializable value or a user-facing error
pub trait Action<T> where T: Serialize {
    // fires the action and returns the payload
    fn call(&self) -> Result<T>;
}

// a result type for actions
pub type Result<T> where T: Serialize =
    std::result::Result<T, Errors>;

// an error type that contains user-facing messages
#[derive(Serialize, Debug)]
pub struct Errors {
    pub messages: String
}

// impls
impl Errors {
    pub fn new<S>(messages: S) -> Errors where S: Into<String> {
        Errors {
            messages: messages.into()
        }
    }
}
