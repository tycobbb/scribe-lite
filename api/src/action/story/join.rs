use core::action::{ Action, Result };
use domain::story;

// types
pub struct Join;

#[derive(Serialize, Debug)]
pub struct Response<'a> {
    text: &'a str,
    name: &'a str
}

// impls
impl<'a> Action<'a, Response<'a>> for Join {
    fn call(&self) -> Result<'a, Response<'a>> {
        let _ = story::Repo.today()
            .or_else(|_| story::Factory.create_for_today());

        Ok(Response {
            name: "Mr. Socket",
            text: "This is the first line."
        })
    }
}
