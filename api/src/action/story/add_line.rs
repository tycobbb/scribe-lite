use core::action::{ Action, Errors, Result };
use core::db::Connected;
use domain::story;

// types
pub struct AddLine;

// impls
impl<'a> Action<'a, ()> for AddLine {
    fn call(&self) -> Result<'a, ()> {
        let repo = story::Repo::connect();

        let mut story = repo
            .today()
            .map_err(AddLine::errors)?;

        story.add_line(
            "This is a real fake line",
            Some("Real Fake"),
            Some("real@fake.com")
        );

        repo.save(&mut story)
            .map_err(AddLine::errors)?;

        Ok(())
    }
}

impl AddLine {
    fn errors<'a>(_: diesel::result::Error) -> Errors<'a> {
        Errors {
            messages: "Errors adding line to story."
        }
    }
}
