use core::db;

// trait
pub trait Connected: From<diesel::PgConnection> {
    // interface
    fn conn(self) -> diesel::PgConnection;

    // factories
    fn connect() -> Self where Self: Sized {
        Self::from(db::connect())
    }

    fn consume<T>(other: T) -> Self where Self: Sized, T: Connected + Sized {
        Self::from(other.conn())
    }
}
