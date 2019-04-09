use diesel::prelude::*;
use super::story::Story;
use super::record::{ Record, NewRecord };

// types
pub struct Factory<'a> {
    conn: &'a diesel::PgConnection
}

// impls
impl<'a> Factory<'a> {
    // init
    pub fn new(conn: &'a diesel::PgConnection) -> Self {
        Factory {
            conn: conn
        }
    }

    // commands
    pub fn create_for_today(&self) -> QueryResult<Story> {
        use crate::core::db::schema::stories;

        diesel::insert_into(stories::table)
            .values(NewRecord::new())
            .get_result::<Record>(self.conn)
            .map(Story::from_record_initial)
    }
}
