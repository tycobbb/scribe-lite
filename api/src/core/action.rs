use serde::Serialize;

// types
// a command type that produces a serializable value or a user-facing error
pub trait Action<'a, T> where T: Serialize {
    // fires the action and returns the payload
    fn call(&self) -> Result<'a, T>;
}

// a result type for actions
pub type Result<'a, T> where T: Serialize =
    std::result::Result<T, Errors<'a>>;

// an error type that contains user-facing messages
#[derive(Serialize, Debug)]
pub struct Errors<'a> {
    pub messages: &'a str
}

// impls
impl<'a> Errors<'a> {
    pub fn new(messages: &'a str) -> Errors<'a> {
        Errors {
            messages: messages
        }
    }
}
