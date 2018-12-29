use action::{ Action, Result };

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
        Ok(Response {
            name: "Mr. Socket",
            text: "This is the first line."
        })
    }
}
