use socket::socket;
use socket::socket::Socket;

pub fn listen() {
    std::thread::spawn(|| {
        ws::listen(socket::HOST, |out| {
            let socket = Socket::new(out);

            move |msg: ws::Message| {
                socket.handle(msg)
            }
        })
    });
}
