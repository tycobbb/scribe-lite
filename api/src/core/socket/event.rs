// types
#[derive(Deserialize, Debug)]
pub enum NameIn {
    #[serde(rename = "STORY.JOIN")]
    StoryJoin,
    #[serde(rename = "STORY.ADD_LINE")]
    StoryAddLine
}

#[derive(Serialize, Debug)]
pub enum NameOut {
    #[serde(rename = "NETWORK_ERROR")]
    NetworkError,
    #[serde(rename = "SHOW_PREVIOUS_LINE")]
    ShowPreviousLine,
    #[serde(rename = "SHOW_THANKS")]
    ShowThanks,
}
