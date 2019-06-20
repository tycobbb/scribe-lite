use super::shared::send_position_updates_to;
use crate::action::action::Action;
use crate::action::event::{Outbound, Scheduled};
use crate::action::routes::Sink;
use crate::core::db;
use crate::domain::story;

// -- types --
#[derive(Debug)]
pub struct TestPulse;

// -- impls --
impl Action for TestPulse {
    type Args = ();

    fn new(_: ()) -> Self {
        TestPulse
    }

    fn call(self, sink: Sink) {
        let conn = db::connect();
        let repo = story::Repo::new(&conn);

        // find story and author
        let mut story = guard!(repo.find_for_today(), else |error| {
            return sink.send(Outbound::show_error(&error))
        });

        let active_author = guard!(story.active_author(), else {
            return
        });

        // if the author is active
        let idle_millis = active_author.idle_millis();

        if idle_millis <= 60 * 1000 {
            // schedule the next pulse check
            let remainder = std::cmp::max(30 * 1000 - idle_millis, 0);
            sink.schedule(Scheduled::FindPulse, remainder as u64);
        } else {
            // otherwise, remove the idle author
            story.remove_active_author();

            if let Err(error) = repo.save_queue(&mut story) {
                return sink.send(Outbound::show_error(&error));
            }

            // send updates to story authors
            sink.send(Outbound::ShowDisconnected);

            for author in story.authors_with_new_positions() {
                send_position_updates_to(author, &story, &sink);
            }
        }
    }
}
