use core::db;
use core::sink::Sink;
use domain::story;
use action::event::*;
use action::action::Action;

// types
pub struct Leave;

// impls
impl<'a> Action<'a> for Leave {
    type Args = ();

    fn call(&self, _: (), sink: Sink<Event>) {
        let conn   = db::connect();
        let repo   = story::Repo::new(&conn);
        let result = repo.find_or_create_for_today();

        let mut story = match result {
            Ok(s)  => s,
            Err(_) => return sink(Event::ShowInternalError)
        };

        story.leave();
    }
}
