/// Allows guard-style statements to unwrap Option and Result types. Supports
/// the following syntax:
///   guard!(<expr -> Option>, else { <return-expr> })
///   guard!(<expr -> Result>, else |_| { <return-expr> })
///   guard!(<expr -> Result>, else |err| { <return-expr> })
#[macro_export]
macro_rules! guard {
    ( $c:expr, else |$err:ident| { $e:expr }) => {{
        match $c {
            Ok(value) => value,
            Err($err) => $e,
        }
    }};
    ( $c:expr, else |_| { $e:expr }) => {{
        match $c {
            Ok(value) => value,
            Err(_) => $e,
        }
    }};
    ( $c:expr, else { $e:expr }) => {{
        match $c {
            Some(value) => value,
            None => $e,
        }
    }};
}
