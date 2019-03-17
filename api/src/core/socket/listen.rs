use super::routes::Routes;
use super::socket::Socket;

// fns
pub fn listen<'a, R>(routes: R) where R: Routes + Clone + Send + 'static {
    // spawn in a thread if using w/ rocket
    // std::thread::spawn(|| {
        Socket.listen(routes);
    // });
}
