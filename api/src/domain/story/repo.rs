use chrono::Utc;
use diesel::prelude::*;
use core::empty;
use super::line;
use super::story::Story;
use super::record::Record;
use super::factory::Factory;

// types
pub struct Repo<'a> {
    conn: &'a diesel::PgConnection
}

// impls
impl<'a> Repo<'a> {
    // init
    pub fn new(conn: &'a diesel::PgConnection) -> Self {
        Repo {
            conn: conn
        }
    }

    // commands
    #[must_use]
    pub fn save_queue(&self, story: &mut Story) -> QueryResult<()> {
        use core::db::schema::stories;

        let target = stories::table
            .filter(stories::id.eq(story.id.0));

        let updated = diesel::update(target)
            .set(story.into_authors_changeset())
            .execute(self.conn);

        updated.map(empty::ignore)
    }

    #[must_use]
    pub fn save_new_line(&self, story: &mut Story) -> QueryResult<()> {
        use core::db::schema::lines;

        let new_line = match story.new_line() {
            Some(line) => line,
            None       => return Ok(())
        };

        let inserted = new_line
            .into_new_record(&story.id)
            .insert_into(lines::table)
            .execute(self.conn);

        inserted.map(empty::ignore)
    }

    #[must_use]
    pub fn save_queue_and_new_line(&self, story: &mut Story) -> QueryResult<()> {
        self.conn.transaction(|| {
            self.save_queue(story)?;
            self.save_new_line(story)
        })
    }

    // queries
    pub fn find_for_today(&self) -> QueryResult<Story> {
        use core::db::schema::{ stories, lines };

        // find today's story
        let midnight = Utc::today()
            .and_hms(0, 0, 0)
            .naive_utc();

        let story = stories::table
            .filter(stories::created_at.gt(midnight))
            .first::<Record>(self.conn)?;

        // find the most recent line
        let lines = line::Record::belonging_to(&story)
            .order_by(lines::created_at.desc())
            .limit(1)
            .load::<line::Record>(self.conn)?;

        Ok(Story::from_record(story, lines))
    }

    pub fn find_or_create_for_today(&self) -> QueryResult<Story> {
        self.find_for_today()
            .or_else(|_| Factory::new(self.conn).create_for_today())
    }
}
