use serde_derive::{ Serialize, Deserialize };

// types
#[derive(Deserialize, Debug)]
pub enum NameIn {
    #[serde(rename = "JOIN_STORY")]
    JoinStory,
    #[serde(rename = "ADD_LINE")]
    AddLine,
    #[serde(rename = "LEAVE_STORY")]
    LeaveStory,
    #[serde(rename = "CHECK_PULSE_1")]
    CheckPulse1
}

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
pub struct Scheduled(
    ws::util::Token
);

// impls
impl Scheduled {
    // options
    pub const CHECK_PULSE_1: Scheduled = Scheduled::val(10);

    // lifetime
    const fn val(value: usize) -> Scheduled {
        Scheduled(ws::util::Token(value))
    }

    pub fn new(token: ws::util::Token) -> Scheduled {
        Scheduled(token)
    }

    // queries
    pub fn token(&self) -> ws::util::Token {
        self.0
    }
}
