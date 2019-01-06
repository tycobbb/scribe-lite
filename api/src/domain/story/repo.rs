use chrono::Utc;
use diesel::prelude::*;
use core::db;
use domain::story::story::Story;
use domain::story::record::Record;

// types
pub struct Repo;

// impls
impl Repo {
    pub fn today(&self) -> QueryResult<Story> {
        use core::db::schema::stories;

        let midnight = Utc::today()
            .and_hms(0, 0, 0)
            .naive_utc();

        stories::table
            .filter(stories::created_at.gt(midnight))
            .first::<Record>(&db::connect())
            .map(Story::from)
    }
}
