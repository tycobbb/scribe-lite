// types
pub type Sink<T> =
    Box<Fn(T) + Send>;
