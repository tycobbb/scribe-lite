use super::line::{self, Line};
use super::queue;
use super::story::Story;
use crate::core::db::schema::stories;
use crate::domain::Id;
use chrono::NaiveDateTime;

// -- types --
#[derive(Debug, Identifiable, Queryable)]
#[table_name = "stories"]
pub struct Record {
    pub id: i32,
    pub created_at: NaiveDateTime,
    pub updated_at: NaiveDateTime,
    pub queue: queue::Column,
}

#[derive(Debug, Insertable)]
#[table_name = "stories"]
pub struct NewRecord {
    pub queue: queue::Column,
}

#[derive(Debug, AsChangeset)]
#[table_name = "stories"]
pub struct QueueChangeset {
    pub queue: queue::Column,
}

// -- impls --
impl NewRecord {
    pub fn new() -> NewRecord {
        NewRecord {
            queue: queue::initial_column_value(),
        }
    }
}

impl Story {
    pub fn from_record_initial(record: Record) -> Self {
        Story::from_record(record, vec![])
    }

    pub fn from_record(record: Record, lines: Vec<line::Record>) -> Self {
        let lines = lines.into_iter().map(Line::from_record);
        let queue = queue::Queue::from_column(record.queue);

        Story::new(Id::from(record.id), queue, lines.collect())
    }

    pub fn make_queue_changeset(&self) -> QueueChangeset {
        QueueChangeset {
            queue: self.queue.into_column(),
        }
    }
}
