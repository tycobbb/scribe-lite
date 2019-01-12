use core::action::{ Action, Errors, Result };
use domain::story;
use core::db::Connected;

// types
pub struct Join;

#[derive(Serialize, Debug)]
pub struct Response {
    text: String,
    name: Option<String>
}

// impls
impl<'a> Action<'a, Option<Response>> for Join {
    fn call(&self) -> Result<'a, Option<Response>> {
        let repo  = story::Repo::connect();
        let story = repo.today()
            .or_else(|_| story::Factory::consume(repo).create_for_today())
            .map_err(Join::errors)?;

        let response = story
            .previous_line()
            .map(Response::from_line);

        Ok(response)
    }
}

impl Join {
    fn errors<'a>(_: diesel::result::Error) -> Errors<'a> {
        Errors {
            messages: "Errors joining story."
        }
    }
}

impl Response {
    fn from_line(line: &story::Line) -> Response {
        Response {
            text: line.text.clone(),
            name: line.name.clone()
        }
    }
}
