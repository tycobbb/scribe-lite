use serde_derive::Deserialize;
use crate::core::db;
use crate::domain::story;
use crate::action::event::Outbound;
use crate::action::routes::Sink;
use crate::action::action::Action;
use super::shared::send_position_updates_to;

// types
#[derive(Debug)]
pub struct AddLine {
    line: NewLine
}

#[derive(Debug, Deserialize)]
pub struct NewLine {
    text:  String,
    name:  Option<String>,
    email: Option<String>
}

// impls
impl Action for AddLine {
    type Args = NewLine;

    fn new(line: NewLine) -> Self {
        AddLine {
            line: line
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

        // finalize the author's line
        story.add_line(
            self.line.text,
            self.line.name,
            self.line.email
        );

        story.leave(sink.id().into());

        if let Err(_) = repo.save_queue_and_new_line(&mut story) {
            return sink.send(Outbound::ShowInternalError);
        }

        // send updates to story authors
        sink.send(Outbound::ShowThanks);

        for author in story.authors_with_new_positions() {
            send_position_updates_to(author, &story, &sink)
        }
    }
}
