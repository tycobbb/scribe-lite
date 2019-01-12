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
    pub name:  &'a str,
    pub text:  &'a str,
    pub email: &'a str,
}

// impls
impl Line {
    pub fn from_db(record: Record) -> Line {
        Line {
            text:  record.text,
            name:  record.name,
            email: record.email
        }
    }
}
