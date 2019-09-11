use crate::action::action::Action;
use crate::action::event::Outbound;
use crate::action::routes::Sink;
use crate::core::db;
use crate::domain::story;
use serde_derive::Deserialize;

// -- types --
#[derive(Debug)]
pub struct SavePulse {
    pulse: Pulse,
}

#[derive(Debug, Deserialize)]
pub struct Pulse {
    timestamp: i64,
}

// -- impls --
impl Action for SavePulse {
    type Args = Pulse;

    fn new(pulse: Pulse) -> Self {
        SavePulse { pulse: pulse }
    }

    fn call(self, sink: Sink) {
        let conn = db::connect();
        let repo = story::Repo::new(&conn);

        // find story
        let mut story = guard!(repo.find_for_today(), else |error| {
            return sink.send(Outbound::show_error(&error))
        });

        // update the author's pulse
        story.update_active_author_pulse(self.pulse.timestamp);
        if let Err(error) = repo.save_queue(&mut story) {
            return sink.send(Outbound::show_error(&error));
        }
    }
}
