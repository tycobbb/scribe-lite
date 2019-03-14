use core::db;
use domain::story;
use action::event::*;
use action::routes::Sink;
use action::action::Action;
use super::notify::notify_new_author;

// types
pub struct Join;

// impls
impl<'a> Action<'a> for Join {
    type Args = ();

    fn call(&self, _: (), sink: Sink) {
        let conn = db::connect();
        let repo = story::Repo::new(&conn);

        // find story
        let mut story = match repo.find_or_create_for_today() {
            Ok(s)  => s,
            Err(_) => return sink.send(Event::ShowInternalError)
        };

        // join story
        story.join(sink.id().into());

        // save updates
        if let Err(_) = repo.save_queue(&mut story) {
            return sink.send(Event::ShowInternalError);
        }

        // notify author
        notify_new_author(&story, &sink);
    }
}
