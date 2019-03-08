// types
#[derive(Debug, PartialEq)]
pub struct Id(
    pub i32
);

// impls
impl From<i32> for Id {
    fn from(value: i32) -> Id {
        Id(value)
    }
}
