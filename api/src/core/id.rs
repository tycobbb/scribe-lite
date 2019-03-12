// types
#[derive(Debug, PartialEq, Eq, Hash, Clone)]
pub struct Id(
    pub u32
);

// impls
impl From<u32> for Id {
    fn from(value: u32) -> Id {
        Id(value)
    }
}

impl From<i32> for Id {
    fn from(value: i32) -> Id {
        Id(value as u32)
    }
}

impl From<&Id> for i32 {
    fn from(value: &Id) -> i32 {
        value.0 as i32
    }
}
