use chrono::Duration;
use crate::core::db;
use crate::domain::story;
use crate::action::action::Action;
use crate::action::event::{ Outbound, Scheduled };
use crate::action::routes::Sink;
use super::shared::send_position_updates_to;

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

        // if the author is active, schedule the next pulse
        let delta = story.active_author()
            .map(|author| author.idle_duration())
            .unwrap_or(Duration::max_value());

        if delta >= Duration::seconds(60) {
            let remainder        = Duration::seconds(30) - delta;
            let remainder_millis = std::cmp::max(remainder.num_milliseconds(), 0);
            sink.schedule(Scheduled::FindPulse, remainder_millis as u64);
            return
        }

        // otherwise, remove the idle author
        story.remove_active_author();

        if let Err(_) = repo.save_queue(&mut story) {
            return sink.send(Outbound::ShowInternalError);
        }

        // send updates to story authors
        sink.send(Outbound::ShowDisconnected);

        for author in story.authors_with_new_positions() {
            send_position_updates_to(author, &story, &sink);
        }
    }
}
