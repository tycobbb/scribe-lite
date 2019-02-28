use std::sync::Arc;
use super::routes::Routes;
use super::socket::Socket;

// fns
pub fn listen(routes: Arc<Routes + Send + Sync>) {
    std::thread::spawn(|| {
        Socket.listen(routes);
    });
}
