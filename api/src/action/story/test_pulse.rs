use chrono::{ DateTime, Utc };
use crate::core::db;
use crate::domain::story;
use crate::action::action::Action;
use crate::action::event::{ Outbound, Scheduled };
use crate::action::routes::Sink;
use super::notify::notify_authors_with_new_positions;

// types
#[derive(Debug)]
pub struct TestPulse;

// impls
impl Action for TestPulse {
    type Args = ();

    fn new(_: ()) -> Self {
        TestPulse
    }

    fn call(self, sink: Sink) {
        let conn = db::connect();
        let repo = story::Repo::new(&conn);

        // find story
        let mut story = match repo.find_for_today() {
            Ok(s)  => s,
            Err(_) => return sink.send(Outbound::ShowInternalError)
        };

        // if the writer isn't idle, schedule the next pulse
        let delta = story.writer_last_active_at()
            .map(|time| Utc::now() - time)
            .map(|time| time.num_milliseconds())
            .unwrap_or(i64::max_value());

        if delta > 60 * 1000 {
            sink.schedule(Scheduled::FindPulse, std::cmp::max(30 * 1000 - delta, 0));
            return
        }

        // otherwise, remove the writer
        story.remove_writer();
        sink.send(Outbound::ShowDisconnected);
        notify_authors_with_new_positions(&story, &sink);

        // save updates
        if let Err(_) = repo.save_queue_and_new_line(&mut story) {
            return sink.send(Outbound::ShowInternalError);
        }
    }
}
