use super::shared::send_position_updates_to;
use crate::action::action::Action;
use crate::action::event::Outbound;
use crate::action::routes::Sink;
use crate::core::db;
use crate::domain::story;

// -- types --
#[derive(Debug)]
pub struct Join;

// -- impls --
impl Action for Join {
    type Args = ();

    fn new(_: ()) -> Self {
        Join
    }

    fn call(self, sink: Sink) {
        let conn = db::connect();
        let repo = story::Repo::new(&conn);

        // find story
        let mut story = match repo.find_or_create_for_today() {
            Ok(s) => s,
            Err(error) => return sink.send(Outbound::show_error(&error)),
        };

        // join story
        story.join(sink.id().into());

        if let Err(error) = repo.save_queue(&mut story) {
            return sink.send(Outbound::show_error(&error));
        }

        // send updates to story authors
        if let Some(author) = story.new_author() {
            send_position_updates_to(author, &story, &sink);
        }
    }
}
