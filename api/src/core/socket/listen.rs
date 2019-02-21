use super::routes::Routes;
use super::socket::Socket;

// fns
pub fn listen<T>(routes: &'static T) where T: Routes + Send + Sync {
    std::thread::spawn(move || {
        Socket.listen(routes);
    });
}
