use chrono::NaiveDateTime;
use core::db::schema::stories;
use domain::Id;
use super::story::Story;
use super::line;
use super::queue;

// types
#[derive(Debug, Identifiable, Queryable)]
#[table_name="stories"]
pub struct Record {
    pub id:         i32,
    pub created_at: NaiveDateTime,
    pub updated_at: NaiveDateTime,
    pub author_ids: Option<Vec<i32>>
}

#[derive(Debug, AsChangeset)]
#[table_name="stories"]
pub struct AuthorsChangeset {
    pub author_ids: Option<Vec<i32>>
}

// impls
impl Story {
    pub fn from_record_initial(record: Record) -> Self {
        Story::from_record(record, vec![])
    }

    pub fn from_record(record: Record, lines: Vec<line::Record>) -> Self {
        let lines = lines
            .into_iter()
            .map(line::Line::from_record);

        let queue =
            queue::Queue::from_column(record.author_ids);

        Story::new(
            Id(record.id),
            queue,
            lines.collect()
        )
    }

    pub fn into_authors_changeset(&self) -> AuthorsChangeset {
        AuthorsChangeset {
            author_ids: self.queue.into_column()
        }
    }
}
