use domain::Id;
use super::queue::Queue;

// types
pub type Column =
    Option<Vec<i32>>;

// impls
impl Queue {
    pub fn from_column(column: Column) -> Self {
        let author_ids = column
            .unwrap_or_default()
            .into_iter()
            .map(Id::from);

        Queue::new(author_ids.collect())
    }

    pub fn into_column(&self) -> Column {
        let ids = self.author_ids.iter()
            .map(|id| id.into());

        Some(ids.collect())
    }
}
