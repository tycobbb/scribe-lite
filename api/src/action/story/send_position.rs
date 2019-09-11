use crate::action::event::{Outbound, Scheduled};
use crate::action::routes::Sink;
use crate::domain::story;

// -- impls --
pub fn to_author(author: story::Author, story: &story::Story, sink: &Sink) {
    match author {
        story::Author::Active(author) => {
            // send the prompt
            let prompt = story.next_line_prompt();
            sink.send_to(author.id, Outbound::ShowPrompt(prompt));

            // schedule the initial pulse check
            sink.schedule_for(
                author.id,
                Scheduled::FindPulse,
                author.find_pulse_at_millis() as u64
            );
        }
        story::Author::Queued(author) => {
            // send the queue position
            let position = author.position.clone();
            sink.send_to(author.id, Outbound::ShowQueue(position));
        }
    };
}
