// types
#[derive(Deserialize, Debug)]
pub enum EventIn {
    #[serde(rename = "STORY.JOIN")]
    StoryJoin,
    #[serde(rename = "STORY.ADD_LINE")]
    StoryAddLine
}

#[derive(Serialize, Debug)]
pub enum EventOut {
    #[serde(rename = "NETWORK_ERROR")]
    NetworkError,
    #[serde(rename = "STORY.JOIN.DONE")]
    StoryJoinDone,
    #[serde(rename = "STORY.ADD_LINE.DONE")]
    StoryAddLineDone,
}

// impls
impl EventIn {
    // queries
    pub fn to_event_out(&self) -> EventOut {
        match self {
            EventIn::StoryJoin    => EventOut::StoryJoinDone,
            EventIn::StoryAddLine => EventOut::StoryAddLineDone
        }
    }
}
