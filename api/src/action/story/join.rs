use core::db;
use domain::story;
use action::event::*;
use action::routes::Sink;
use action::action::Action;

// types
pub struct Join;

// impls
impl<'a> Action<'a> for Join {
    type Args = ();

    fn call(&self, _: (), sink: Sink) {
        let conn = db::connect();
        let repo = story::Repo::new(&conn);

        // find story
        let mut story = match repo.find_or_create_for_today() {
            Ok(s)  => s,
            Err(_) => return sink.send(Event::ShowInternalError)
        };

        // join story
        story.join(sink.id().into());

        // save updates
        if let Err(_) = repo.save_queue(&mut story) {
            return sink.send(Event::ShowInternalError);
        }

        // send updates to story authors
        // TODO: share with other actions
        let author = match story.new_author() {
            Some(author) => author,
            None         => return sink.send(Event::ShowInternalError)
        };

        if author.is_active() {
            sink.send(Event::ShowPrompt(story.next_line_prompt()));
        } else {
            sink.send(Event::ShowQueue(author.position));
        }
    }
}
