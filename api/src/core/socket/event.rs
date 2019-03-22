use serde_derive::{ Serialize, Deserialize };

// types
#[derive(Serialize, Debug)]
pub enum NameOut {
    // story
    #[serde(rename = "SHOW_PROMPT")]
    ShowPrompt,
    #[serde(rename = "SHOW_QUEUE")]
    ShowQueue,
    #[serde(rename = "SHOW_THANKS")]
    ShowThanks,
    #[serde(rename = "CHECK_PULSE")]
    CheckPulse,
    // shared
    #[serde(rename = "SHOW_INTERNAL_ERROR")]
    ShowInternalError
}

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
