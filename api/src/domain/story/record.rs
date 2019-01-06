use chrono::{ NaiveDateTime };
use domain::story::story::Story;

// types
#[derive(Queryable)]
#[table_name="stories"]
pub struct Record {
    pub id: i32,
    pub created_at: NaiveDateTime,
    pub updated_at: NaiveDateTime
}

// impls
impl From<Record> for Story {
    fn from(record: Record) -> Story {
        Story {
            id: record.id
        }
    }
}
