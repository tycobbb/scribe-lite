use serde_json as json;
use serde_derive::{ Serialize, Deserialize };
use chrono::NaiveDateTime;
use crate::domain::Id;
use super::queue::Queue;
use super::author::Author;

// types
pub type Column =
    Option<json::Value>;

#[derive(Debug, Serialize, Deserialize)]
pub struct Record {
    pub author_ids:     Vec<i32>,
    pub last_active_at: Option<NaiveDateTime>
}

// impls
impl Queue {
    pub fn from_column(column: Column) -> Self {
        let record = column
            .map(json::from_value::<Record>)
            .transpose()
            .unwrap_or_else(|error| {
                error!("[domain] failed to deserialize queue error={}", error);
                None
            });

        let Record { author_ids, last_active_at } = match record {
            Some(record) => record,
            None         => return Queue::new(Vec::new())
        };

        let authors = author_ids
            .into_iter()
            .map(Id::from)
            .enumerate()
            .map(|(i, id)| {
                match i {
                    0 => Author::writer(id, last_active_at),
                    _ => Author::waiter(id, i)
                }
            });

        Queue::new(authors.collect())
    }

    pub fn into_column(&self) -> Column {
        let author_ids = self.author_ids()
            .into_iter()
            .map(|id| id.into());

        let record: Record = Record {
            author_ids:     author_ids.collect(),
            last_active_at: self.last_active_at()
        };

        json::to_value(record)
            .map(Some)
            .unwrap_or_else(|error| {
                error!("[domain] failed to serialize queue error={}", error);
                None
            })
    }
}
