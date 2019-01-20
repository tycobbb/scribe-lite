use chrono::NaiveDateTime;
use core::db::schema::lines;
use domain::story::Record as Story;
use domain::story::line::Line;

// types
#[derive(Identifiable, Associations, Queryable)]
#[belongs_to(Story)]
#[table_name="lines"]
pub struct Record {
    pub id:         i32,
    pub text:       String,
    pub name:       Option<String>,
    pub email:      Option<String>,
    pub story_id:   i32,
    pub created_at: NaiveDateTime,
    pub updated_at: NaiveDateTime
}

#[derive(Insertable)]
#[table_name="lines"]
pub struct NewRecord<'a> {
    pub text:     &'a str,
    pub name:     Option<&'a str>,
    pub email:    Option<&'a str>,
    pub story_id: i32
}

// impls
impl Line {
    pub fn from_db(record: Record) -> Self {
        Line::new(
            record.text,
            record.name,
            record.email
        )
    }

    pub fn to_new_record(&self, story_id: i32) -> NewRecord {
        NewRecord {
            text:     &self.text,
            name:     self.name.as_ref().map(String::as_ref),
            email:    self.email.as_ref().map(String::as_ref),
            story_id: story_id
        }
    }
}
