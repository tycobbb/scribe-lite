// types
#[derive(Debug, PartialEq, Eq)]
pub struct Timeout(
    usize
);

// impls
impl Timeout {
    pub fn new(value: usize) -> Timeout {
        Timeout(value)
    }

    // queries
    pub fn token(&self) -> ws::util::Token {
        ws::util::Token(self.0)
    }

    pub fn value(&self) -> usize {
        self.token().0
    }
}
