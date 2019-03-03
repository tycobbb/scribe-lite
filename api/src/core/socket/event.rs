// types
#[derive(Deserialize, Debug)]
pub enum NameIn {
    #[serde(rename = "JOIN_STORY")]
    JoinStory,
    #[serde(rename = "ADD_LINE")]
    AddLine
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
    #[serde(rename = "SHOW_ADD_LINE_ERROR")]
    ShowAddLineError,
    // shared
    #[serde(rename = "SHOW_INTERNAL_ERROR")]
    ShowInternalError
}
