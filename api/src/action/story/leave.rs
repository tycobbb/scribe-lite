use super::shared::send_position_updates_to;
use crate::action::action::Action;
use crate::action::event::Outbound;
use crate::action::routes::Sink;
use crate::core::db;
use crate::domain::story;

// -- types --
#[derive(Debug)]
pub struct Leave;

// -- impls --
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
            Ok(s) => s,
            Err(error) => return sink.send(Outbound::show_error(&error)),
        };

        // leave story
        story.leave(sink.id());

        if let Err(error) = repo.save_queue(&mut story) {
            return sink.send(Outbound::show_error(&error));
        }

        // send updates to story authors
        for author in story.authors_with_new_positions() {
            send_position_updates_to(author, &story, &sink);
        }
    }
}
