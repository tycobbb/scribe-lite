use core::db;

// trait
pub trait Connected {
    // interface
    fn conn(self) -> diesel::PgConnection;
    fn from_conn(conn: diesel::PgConnection) -> Self where Self: Sized;

    // factories
    fn connect() -> Self where Self: Sized {
        Self::from_conn(db::connect())
    }

    fn consume<T>(other: T) -> Self where Self: Sized, T: Connected + Sized {
        Self::from_conn(other.conn())
    }
}
