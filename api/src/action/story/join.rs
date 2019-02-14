use core::action;
use core::db::Connected;
use domain::story;
use action::event::*;

// types
pub struct Join;

// impls
impl<'a> Join {
    pub fn call(&self) -> Event<'a> {
        let repo   = story::Repo::connect();
        let prompt = repo.today()
            .or_else(|_| story::Factory::consume(repo).create_for_today())
            .map_err(Join::errors)
            .map(|story| story.next_line_prompt());

        Event::ShowPreviousLine(prompt)
    }
}

impl Join {
    fn errors<'a>(_: diesel::result::Error) -> action::Errors<'a> {
        action::Errors {
            messages: "Errors joining story."
        }
    }
}
