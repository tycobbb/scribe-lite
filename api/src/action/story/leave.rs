use core::db;
use domain::story;
use action::event::Event;
use action::routes::Sink;
use action::action::Action;
use super::notify::notify_authors_with_new_positions;


// types
pub struct Leave;

// impls
impl<'a> Action<'a> for Leave {
    type Args = ();

    fn call(&self, _: (), sink: Sink) {
        let conn = db::connect();
        let repo = story::Repo::new(&conn);

        // find story
        let mut story = match repo.find_for_today() {
            Ok(s)  => s,
            Err(_) => return sink.send(Event::ShowInternalError)
        };

        // leave story
        story.leave(sink.id());

        // save updates
        if let Err(_) = repo.save_queue(&mut story) {
            return sink.send(Event::ShowInternalError);
        }

        // send updates to story authors
        notify_authors_with_new_positions(&story, &sink);
    }
}
