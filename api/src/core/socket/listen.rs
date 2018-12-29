use socket::socket;
use socket::socket::Socket;
use socket::routes::Routes;

pub fn listen<T>(routes: &'static T) where T: Routes + Send + Sync {
    std::thread::spawn(move || {
        ws::listen(socket::HOST, |out| {
            let socket = Socket::new(out, routes);

            move |msg: ws::Message| {
                socket.handle(msg)
            }
        })
    });
}
