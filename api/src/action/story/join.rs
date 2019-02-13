use core::action::{ Action, Errors, Result };
use core::db::Connected;
use domain::story;

// types
pub struct Join;

#[derive(Serialize, Debug)]
pub struct Response {
    text: String,
    name: Option<String>
}

// impls
impl<'a> Action<'a, Response> for Join {
    fn call(&self) -> Result<'a, Response> {
        let repo  = story::Repo::connect();
        let story = repo.today()
            .or_else(|_| story::Factory::consume(repo).create_for_today())
            .map_err(Join::errors)?;

        let response = story
            .previous_line()
            .map(Response::from_line)
            .unwrap_or_default();

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
    fn from_line(line: &story::Line) -> Self {
        Response {
            text: line.text.clone(),
            name: line.name.clone()
        }
    }
}

impl Default for Response {
    fn default() -> Self {
        Response {
            text: "You get to write the first line! Follow your heart <3".to_string(),
            name: None
        }
    }
}
