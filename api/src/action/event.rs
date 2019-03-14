use domain::story;

// types
// Event is a list of events that actions can trigger.
#[derive(Debug)]
pub enum Event {
    // story
    ShowQueue(story::Position),
    ShowPrompt(story::Prompt),
    ShowThanks,
    CheckPulse1,
    // shared
    ShowInternalError
}
