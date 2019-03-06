use core::db;
use domain::story;
use action::event::*;
use action::routes::Sink;
use action::action::Action;

// types
pub struct Join;

// impls
impl<'a> Action<'a> for Join {
    type Args = ();

    fn call(&self, _: (), sink: Sink) {
        let conn   = db::connect();
        let repo   = story::Repo::new(&conn);
        let result = repo.find_or_create_for_today();

        let mut story = match result {
            Ok(s)  => s,
            Err(_) => return sink.send(Event::ShowInternalError)
        };

        if story.is_available() {
            story.join(story::Author::Active);
            sink.send(Event::ShowPrompt(story.next_line_prompt()));
        } else {
            story.join(story::Author::Waiting(self.on_new_position(sink))
        }
    }
}

impl Join {
    // async events
    fn on_new_position(&self, sink: Sink<Event>) -> Sink<story::Position> {
        Box::new(move |position| {
            let conn  = db::connect();
            let repo  = story::Repo::new(&conn);
            let story = match repo.find_for_today() {
                Ok(s)  => s,
                Err(_) => return sink(Event::ShowInternalError)
            };

            if position.is_ready() {
                sink(Event::ShowPrompt(story.next_line_prompt()));
            } else {
                sink(Event::ShowQueue(position));
            }
        })
    }
}
