use super::send_position;
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
        let mut story = guard!(repo.find_or_create_for_today(), else |error| {
            return sink.send(Outbound::show_error(&error))
        });

        // join story
        story.join(sink.id());
        if let Err(error) = repo.save_queue(&mut story) {
            return sink.send(Outbound::show_error(&error));
        }

        // broadcast position to new author
        if let Some(author) = story.new_author() {
            send_position::to_author(author, &story, &sink);
        }
    }
}
