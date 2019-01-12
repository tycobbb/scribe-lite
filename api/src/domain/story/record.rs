use chrono::{ NaiveDateTime };
use core::db::schema::stories;
use domain::story::story::Story;
use domain::story::line;

// types
#[derive(Identifiable, Queryable)]
#[table_name="stories"]
pub struct Record {
    pub id:         i32,
    pub created_at: NaiveDateTime,
    pub updated_at: NaiveDateTime
}

// impls
impl Story {
    pub fn from_db_with_defaults(record: Record) -> Story {
        Story::from_db(record, vec![])
    }

    pub fn from_db(_: Record, lines: Vec<line::Record>) -> Story {
        let lines = lines
            .into_iter()
            .map(line::Line::from_db);

        Story {
            lines: lines.collect()
        }
    }
}
