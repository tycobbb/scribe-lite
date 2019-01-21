use yansi::Paint;
use socket::socket;
use socket::socket::Socket;
use socket::routes::Routes;

pub fn listen<T>(routes: &'static T) where T: Routes + Send + Sync {
    std::thread::spawn(move || {
        println!("🧦  {} {}",
            Paint::default("Socket is listening on").bold(),
            Paint::default(socket::HOST.replace("127.0.0.1", "http://localhost")).bold().underline()
        );

        ws::listen(socket::HOST, |out| {
            let socket = Socket::new(out, routes);

            move |msg: ws::Message| {
                socket.handle(msg)
            }
        })
    });
}
