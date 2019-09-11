use super::send_position;
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

        // if the author was active in the last 60s, schedule a new check
        if !active_author.is_idle() {
            sink.schedule(
                Scheduled::FindPulse,
                active_author.find_pulse_at_millis() as u64,
            );
            return
        }

        // otherwise, the author is idling so remove them
        story.remove_active_author();
        if let Err(error) = repo.save_queue(&mut story) {
            return sink.send(Outbound::show_error(&error));
        }

        // and send new positions to queued authors
        sink.send(Outbound::ShowDisconnected);
        for author in story.authors_with_new_positions() {
            send_position::to_author(author, &story, &sink);
        }
    }
}
