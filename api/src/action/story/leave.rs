use crate::core::db;
use crate::domain::story;
use crate::action::event;
use crate::action::routes::Sink;
use crate::action::action::Action;
use super::shared::send_position_updates_to;

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
            Err(_) => return sink.send(event::Outbound::ShowInternalError)
        };

        // leave story
        story.leave(sink.id());

        if let Err(_) = repo.save_queue(&mut story) {
            return sink.send(event::Outbound::ShowInternalError);
        }

        // send updates to story authors
        for author in story.authors_with_new_positions() {
            send_position_updates_to(author, &story, &sink);
        }
    }
}
