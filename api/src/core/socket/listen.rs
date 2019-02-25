use std::rc::Rc;
use super::routes::Routes;
use super::socket::Socket;

// fns
pub fn listen<R>(make_routes: R) where R: (FnOnce() -> Rc<Routes>) + Send + 'static {
    std::thread::spawn(|| {
        Socket.listen(make_routes());
    });
}
