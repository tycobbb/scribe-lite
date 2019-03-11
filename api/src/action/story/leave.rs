use core::db;
use domain::story;
use action::event::*;
use action::routes::Sink;
use action::action::Action;

// types
pub struct Leave;

// impls
impl<'a> Action<'a> for Leave {
    type Args = ();

    fn call(&self, _: (), sink: Sink) {
        let conn = db::connect();
        let repo = story::Repo::new(&conn);

        // find story
        let mut story = match repo.find_for_today() {
            Ok(s)  => s,
            Err(_) => return sink.send(Event::ShowInternalError)
        };

        // leave story
        story.leave(sink.id().into());

        // save updates
        if let Err(_) = repo.save_queue(&mut story) {
            return sink.send(Event::ShowInternalError);
        }

        // send updates to story authors
        // TODO: share with other actions
        for author in story.authors_with_new_positions() {
            if author.is_active() {
                sink.send_to(author.id.0 as u32, Event::ShowPrompt(story.next_line_prompt()));
            } else {
                sink.send_to(author.id.0 as u32, Event::ShowQueue(author.position));
            }
        }
    }
}
