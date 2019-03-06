use super::routes::Routes;
use super::socket::Socket;

// fns
pub fn listen<'a, R>(routes: R) where R: Routes + Clone + Send + 'static {
    std::thread::spawn(|| {
        Socket.listen(routes);
    });
}
