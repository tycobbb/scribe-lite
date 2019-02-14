use chrono::NaiveDateTime;
use core::db::schema::stories;
use super::Story;
use super::line;

// types
#[derive(Debug, Identifiable, Queryable)]
#[table_name="stories"]
pub struct Record {
    pub id:         i32,
    pub created_at: NaiveDateTime,
    pub updated_at: NaiveDateTime
}

// impls
impl Story {
    pub fn from_db_initial(record: Record) -> Self {
        Story::from_db(record, vec![])
    }

    pub fn from_db(record: Record, lines: Vec<line::Record>) -> Self {
        let lines = lines
            .into_iter()
            .map(line::Line::from_db);

        Story::new(
            record.id,
            lines.collect()
        )
    }
}
