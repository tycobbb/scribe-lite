use chrono::Utc;
use diesel::prelude::*;
use core::db;
use core::empty;
use domain::story::{ self, line };

// types
pub struct Repo {
    conn: diesel::PgConnection
}

// impls
impl Repo {
    // commands
    #[must_use]
    pub fn save(&self, story: &mut story::Story) -> QueryResult<()> {
        use core::db::schema::lines;

        if let Some(line) = story.new_line() {
            line
                .to_new_record(story.id)
                .insert_into(lines::table)
                .execute(&self.conn)
                .map(empty::ignore)?;
        }

        Ok(())
    }

    // queries
    pub fn today(&self) -> QueryResult<story::Story> {
        use core::db::schema::{ stories, lines };

        // find today's story
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

    fn from_conn(conn: diesel::PgConnection) -> Self {
        Repo {
            conn: conn
        }
    }
}
