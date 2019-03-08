use domain::Id;

// types
#[derive(Debug)]
pub struct Author<'a> {
    id:       &'a Id,
    position: Position
}

#[derive(Debug, Serialize)]
pub struct Position {
    behind: usize
}

// impls
impl<'a> Author<'a> {
    // init / factories
    pub fn new(id: &'a Id, behind: usize) -> Author<'a> {
        Author {
            id: id,
            position: Position {
                behind: behind
            }
        }
    }
}
