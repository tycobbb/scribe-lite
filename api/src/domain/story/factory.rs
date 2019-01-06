use diesel::prelude::*;
use core::db;
use domain::story::story::Story;
use domain::story::record::Record;

// types
pub struct Factory;

// impls
impl Factory {
    pub fn create_for_today(&self) -> QueryResult<Story> {
        use core::db::schema::stories;

        diesel::insert_into(stories::table)
            .default_values()
            .get_result::<Record>(&db::connect())
            .map(Story::from)
    }
}
