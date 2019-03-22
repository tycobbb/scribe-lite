use crate::core::db;
use crate::domain::story;
use crate::action::event::Event;
use crate::action::routes::Sink;
use crate::action::action::Action;
use super::notify::notify_authors_with_new_positions;

// types
#[derive(Debug)]
pub struct Leave;

// impls
impl Action for Leave {
    type Args = ();

    fn new(_: ()) -> Self {
        Leave
    }

    fn call(self, sink: Sink) {
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
