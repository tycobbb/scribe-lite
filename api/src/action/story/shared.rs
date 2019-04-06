use crate::domain::story;
use crate::action::event::{ Outbound, Scheduled };
use crate::action::routes::Sink;

pub fn send_position_updates_to(author: story::Author, story: &story::Story, sink: &Sink) {
    match author {
        story::Author::Active(author) => {
            let prompt = story.next_line_prompt();
            sink.send_to(author.id, Outbound::ShowPrompt(prompt));
            sink.schedule_for(author.id, Scheduled::FindPulse, 30 * 1000);
        }
        story::Author::Queued(author) => {
            let position = author.position.clone();
            sink.send_to(author.id, Outbound::ShowQueue(position));
        }
    };
}
