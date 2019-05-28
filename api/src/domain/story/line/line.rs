// -- types --
#[derive(Debug)]
pub struct Line {
    pub text: String,
    pub name: Option<String>,
    pub email: Option<String>,
}

// -- impls --
impl Line {
    pub fn new(text: String, name: Option<String>, email: Option<String>) -> Self {
        Line {
            text: text,
            name: name,
            email: email,
        }
    }
}
