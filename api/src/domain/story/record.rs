use chrono::NaiveDateTime;
use core::db::schema::stories;
use domain::Id;
use super::story::Story;
use super::queue::{ Queue, Author };
use super::line;

// types
#[derive(Debug, Identifiable, Queryable)]
#[table_name="stories"]
pub struct Record {
    pub id:         i32,
    pub created_at: NaiveDateTime,
    pub updated_at: NaiveDateTime,
    pub queue:      Option<Vec<i32>>
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

        let author_ids = record.queue
            .unwrap_or_default()
            .into_iter()
            .map(Id);

        Story::new(
            Id(record.id),
            Queue::new(author_ids.collect()),
            lines.collect()
        )
    }
}
