use domain::story;
use action::event::*;
use action::routes::Sink;

pub fn notify_new_author(story: &story::Story, sink: &Sink) {
    match story.new_author() {
        Some(author) => notify_author(author, story, sink),
        None         => sink.send(Event::ShowInternalError)
    };
}

pub fn notify_authors_with_new_positions(story: &story::Story, sink: &Sink) {
    for author in story.authors_with_new_positions() {
        notify_author(author, story, sink);
    }
}

fn notify_author(author: story::Author, story: &story::Story, sink: &Sink) {
    if !author.is_active() {
        sink.send(Event::ShowQueue(author.position));
        return
    }

    // show prompt
    sink.send(Event::ShowPrompt(story.next_line_prompt()));
    // schedule first pulse check in 30s
    sink.schedule(30_000, Event::CheckPulse1);
}
