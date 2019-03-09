use domain::Id;

// types
#[derive(Debug)]
pub struct Author<'a> {
    pub id:       &'a Id,
    pub position: Position
}

#[derive(Debug, Serialize)]
pub struct Position {
    pub behind: usize
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

    // queries
    pub fn is_active(&self) -> bool {
        self.position.behind == 0
    }
}
