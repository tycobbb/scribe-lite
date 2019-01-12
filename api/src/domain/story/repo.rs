use chrono::Utc;
use diesel::prelude::*;
use core::db;
use domain::story;
use domain::story::line;

// types
pub struct Repo {
    conn: diesel::PgConnection
}

// impls
impl Repo {
    pub fn today(&self) -> QueryResult<story::Story> {
        use core::db::schema::{ stories, lines };

        // find todays story
        let midnight = Utc::today()
            .and_hms(0, 0, 0)
            .naive_utc();

        let story = stories::table
            .filter(stories::created_at.gt(midnight))
            .first::<story::Record>(&self.conn)?;

        // find the most recent line
        let lines = line::Record::belonging_to(&story)
            .order_by(lines::created_at.desc())
            .limit(1)
            .load::<line::Record>(&self.conn)?;

        Ok(story::Story::from_db(story, lines))
    }
}

impl db::Connected for Repo {
    fn conn(self) -> diesel::PgConnection {
        self.conn
    }
}

impl From<diesel::PgConnection> for Repo {
    fn from(conn: diesel::PgConnection) -> Repo {
        Repo {
            conn: conn
        }
    }
}
