use super::queue::Queue;
use crate::domain::Id;
use chrono::Utc;
use serde_derive::{Deserialize, Serialize};
use serde_json as json;

// -- types --
pub type Column = json::Value;

#[derive(Debug, Serialize, Deserialize)]
pub struct Record {
    pub author_ids: Vec<i32>,
    pub author_pulse_millis: i64,
}

// -- impls --
// TODO: figure out how to newtype column so that it can be used w/
// diesel, and move this fn there
pub fn initial_column_value() -> Column {
    let record = Record {
        author_ids: Vec::new(),
        author_pulse_millis: Utc::now().timestamp_millis(),
    };

    record.encode()
}

impl Record {
    // json
    fn decode(column: Column) -> Record {
        json::from_value::<Record>(column)
            .map_err(|error| format!("[domain] failed to decode queue error={}", error))
            .unwrap()
    }

    fn encode(&self) -> Column {
        json::to_value(self)
            .map_err(|error| format!("[domain] failed to encode queue error={}", error))
            .unwrap()
    }
}

impl Queue {
    pub fn from_column(column: Column) -> Self {
        let record = Record::decode(column);
        let author_ids = record.author_ids.into_iter().map(Id::from);

        Queue::new(author_ids.collect(), record.author_pulse_millis)
    }

    pub fn into_column(&self) -> Column {
        let author_ids = self.author_ids.iter().map(|id| id.into());

        let record: Record = Record {
            author_ids: author_ids.collect(),
            author_pulse_millis: self.author_pulse_millis,
        };

        record.encode()
    }
}
