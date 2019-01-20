use diesel::prelude::*;
use core::db;
use domain::story::story::Story;
use domain::story::record::Record;

// types
pub struct Factory {
    conn: diesel::PgConnection
}

// impls
impl Factory {
    pub fn create_for_today(&self) -> QueryResult<Story> {
        use core::db::schema::stories;

        diesel::insert_into(stories::table)
            .default_values()
            .get_result::<Record>(&self.conn)
            .map(Story::from_db_initial)
    }
}

impl db::Connected for Factory {
    fn conn(self) -> diesel::PgConnection {
        self.conn
    }

    fn from_conn(conn: diesel::PgConnection) -> Self {
        Factory {
            conn: conn
        }
    }
}
