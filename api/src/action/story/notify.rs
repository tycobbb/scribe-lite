use crate::domain::story;
use crate::action::event::{ Outbound, Scheduled };
use crate::action::routes::Sink;

pub fn notify_new_author(story: &story::Story, sink: &Sink) {
    match story.new_author() {
        Some(author) => notify_author(author, story, sink),
        None         => sink.send(Outbound::ShowInternalError)
    };
}

pub fn notify_authors_with_new_positions(story: &story::Story, sink: &Sink) {
    for author in story.authors_with_new_positions() {
        notify_author(author, story, sink);
    }
}

fn notify_author(author: story::Author, story: &story::Story, sink: &Sink) {
    match author {
        story::Author::Active(_) => {
            sink.send(Outbound::ShowPrompt(story.next_line_prompt()));
            sink.schedule(Scheduled::FindPulse, 30 * 1000);
        }
        story::Author::Queued(author) => {
            sink.send(Outbound::ShowQueue(author.position.clone()))
        }
    };
}
