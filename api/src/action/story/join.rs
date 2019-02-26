use core::db;
use domain::story;
use action::event::*;
use action::action::Action;

// types
pub struct Join;

// impls
impl<'a> Action<'a> for Join {
    type Args = ();

    fn call(&self, _: (), sink: Box<Fn(Event)>) {
        let conn   = db::connect();
        let repo   = story::Repo::new(&conn);
        let result = repo.find_or_create_for_today();

        let mut story = match result {
            Ok(s)  => s,
            Err(_) => return sink(Event::ShowInternalError)
        };

        if story.is_available() {
            story.join(story::Author::Active);
            sink(Event::ShowPrompt(Ok(story.next_line_prompt())));
        } else {
            story.join(story::Author::Waiting(self.on_new_position(sink))
        }
    }
}

impl Join {
    // events
    fn on_new_position(&self, sink: Box<Fn(Event)>) -> Box<Fn(story::Position)> {
        Box::new(move |position| {
            let conn  = db::connect();
            let repo  = story::Repo::new(&conn);
            let story = match repo.find_for_today() {
                Ok(s)  => s,
                Err(_) => return sink(Event::ShowInternalError)
            };

            match position {
                story::Position::Ready =>
                    sink(Event::ShowPrompt(Ok(story.next_line_prompt()))),
                story::Position::Behind(others) =>
                    sink(Event::ShowQueue(Ok(others)))
            };
        })
    }
}
