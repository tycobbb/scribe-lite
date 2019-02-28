use core::db;
use core::sink::Sink;
use domain::story;
use action::action::{ self, Action };
use action::event::*;

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

    fn call(&self, line: NewLine<'a>, sink: Sink<Event>) {
        let conn = db::connect();
        let repo = story::Repo::new(&conn);

        let result = repo
            .find_for_today()
            .map_err(AddLine::errors);

        let mut story = match result {
            Ok(s)  => s,
            Err(e) => return sink(Event::ShowThanks(Err(e)))
        };

        story.add_line(
            line.text,
            line.name,
            line.email
        );

        let result = repo.save(&mut story)
            .map_err(AddLine::errors);

        if let Err(e) = result {
            return sink(Event::ShowThanks(Err(e)));
        }

        story.leave();

        sink(Event::ShowThanks(Ok(())))
    }
}

impl AddLine {
    fn errors(_: diesel::result::Error) -> action::Error {
        action::Error::new(
            "Errors adding line to story."
        )
    }
}
