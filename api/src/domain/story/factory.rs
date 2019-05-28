use super::record::{NewRecord, Record};
use super::story::Story;
use diesel::prelude::*;

// -- types --
pub struct Factory<'a> {
    conn: &'a diesel::PgConnection,
}

// -- impls --
impl<'a> Factory<'a> {
    // -- impls/init
    pub fn new(conn: &'a diesel::PgConnection) -> Self {
        Factory { conn: conn }
    }

    // -- impls/commands
    pub fn create_for_today(&self) -> QueryResult<Story> {
        use crate::core::db::schema::stories;

        diesel::insert_into(stories::table)
            .values(NewRecord::new())
            .get_result::<Record>(self.conn)
            .map(Story::from_record_initial)
    }
}
