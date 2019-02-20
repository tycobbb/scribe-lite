use yansi::Paint;
use super::socket::{ self, Socket };
use super::routes::Routes;

// constants
pub const HOST: &'static str = "127.0.0.1:8080";

// fns
pub fn listen<T>(routes: &'static T) where T: Routes + Send + Sync {
    std::thread::spawn(move || {
        println!("🧦  {} {}",
            Paint::default("Socket is listening on").bold(),
            Paint::default(HOST.replace("127.0.0.1", "http://localhost")).bold().underline()
        );

        ws::listen(HOST, |out| {
            let socket = Socket::new(out, routes);

            move |msg: ws::Message| {
                socket.handle(msg)
            }
        })
    });
}
