use diesel::prelude::*;
use super::story::Story;
use super::record::Record;

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
        use core::db::schema::stories;

        diesel::insert_into(stories::table)
            .default_values()
            .get_result::<Record>(self.conn)
            .map(Story::from_db_initial)
    }
}
