use serde_json as json;
use serde_derive::{ Serialize, Deserialize };
use chrono::{ DateTime, NaiveDateTime, Utc };
use crate::domain::Id;
use super::queue::Queue;

// types
pub type Column =
    Option<json::Value>;

#[derive(Debug, Serialize, Deserialize)]
pub struct Record {
    pub author_ids:         Vec<i32>,
    pub author_rustle_time: Option<NaiveDateTime>
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

        let record = match record {
            Some(record) => record,
            None         => return Queue::new(Vec::new(), None)
        };

        let author_ids = record.author_ids
            .into_iter()
            .map(Id::from);

        let author_rustle_time = record.author_rustle_time
            .map(|time| DateTime::from_utc(time, Utc));

        Queue::new(
            author_ids.collect(),
            author_rustle_time
        )
    }

    pub fn into_column(&self) -> Column {
        let author_ids = self.author_ids
            .iter()
            .map(|id| id.into());

        let author_rustle_time = self.author_rustle_time
            .map(|time| time.naive_utc());

        let record: Record = Record {
            author_ids:         author_ids.collect(),
            author_rustle_time: author_rustle_time
        };

        json::to_value(record)
            .map(Some)
            .unwrap_or_else(|error| {
                error!("[domain] failed to serialize queue error={}", error);
                None
            })
    }
}
