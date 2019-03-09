use core::db;
use domain::story;
use action::event::*;
use action::routes::Sink;
use action::action::Action;

// types
pub struct AddLine;

#[derive(Deserialize, Debug)]
pub struct NewLine<'a> {
    text:  &'a str,
    name:  Option<&'a str>,
    email: Option<&'a str>
}

// impls
impl<'a> Action<'a> for AddLine {
    type Args = NewLine<'a>;

    fn call(&self, line: NewLine<'a>, sink: Sink) {
        let conn = db::connect();
        let repo = story::Repo::new(&conn);

        // find story
        let mut story = match repo.find_for_today() {
            Ok(s)  => s,
            Err(_) => return sink.send(Event::ShowInternalError)
        };

        // add line to story
        story.add_line(
            line.text,
            line.name,
            line.email
        );

        story.leave(sink.id().into());

        // save updates
        if let Err(_) = repo.save_queue_and_new_line(&mut story) {
            return sink.send(Event::ShowInternalError);
        }

        // send updates to story authors
        // TODO: share this with the other actions
        for author in story.authors_with_new_positions() {
            if author.is_active() {
                sink.send(Event::ShowPrompt(story.next_line_prompt()));
            } else {
                sink.send(Event::ShowQueue(author.position));
            }
        }

        sink.send(Event::ShowThanks);
    }
}
