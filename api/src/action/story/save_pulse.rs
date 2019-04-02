use chrono::NaiveDateTime;
use serde_derive::Deserialize;
use crate::core::db;
use crate::domain::story;
use crate::action::action::Action;
use crate::action::event::Outbound;
use crate::action::routes::Sink;

// types
#[derive(Debug)]
pub struct SavePulse {
    pulse: Pulse,
}

#[derive(Debug, Deserialize)]
pub struct Pulse {
    timestamp: NaiveDateTime,
}

// impls
impl Action for SavePulse {
    type Args = Pulse;

    fn new(pulse: Pulse) -> Self {
        SavePulse {
            pulse: pulse
        }
    }

    fn call(self, sink: Sink) {
        let conn = db::connect();
        let repo = story::Repo::new(&conn);

        // find story
        let mut story = match repo.find_for_today() {
            Ok(s)  => s,
            Err(_) => return sink.send(Outbound::ShowInternalError)
        };

        // update the timestamp
        story.touch(self.pulse.timestamp);

        // save updates
        if let Err(_) = repo.save_queue(&mut story) {
            return sink.send(Outbound::ShowInternalError);
        }
    }
}
