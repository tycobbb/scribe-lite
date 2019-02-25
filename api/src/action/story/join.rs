use core::db::Connected;
use domain::story;
use action::action::{ self, Action };
use action::event::*;

// types
pub struct Join;

// impls
impl<'a> Action<'a> for Join {
    type Args = ();

    fn call(&self, _: (), sink: Box<Fn(Event)>) {
        let repo   = story::Repo::connect();
        let prompt = repo.today()
            .or_else(|_| story::Factory::consume(repo).create_for_today())
            .map_err(Join::errors)
            .map(|story| story.next_line_prompt());

        sink(Event::ShowPrompt(prompt));
    }
}

impl Join {
    fn errors(_: diesel::result::Error) -> action::Error {
        action::Error::new(
            "Errors joining story."
        )
    }
}
