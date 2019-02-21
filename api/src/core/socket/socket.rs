use yansi::{ Paint, Color };
use super::routes::Routes;
use super::connection::Connection;

// constants
const HOST: &'static str = "127.0.0.1:8080";

// types
pub struct Socket;

// impls
impl Socket {
    pub fn listen<T>(&self, routes: &'static T) where T: Routes + Send + Sync {
        let result = ws::listen(HOST, |out| {
            let connection = Connection::new(out, routes);
            move |msg: ws::Message| {
                connection.handle(msg)
            }
        });

        self.notify(result);
    }

    fn notify(&self, result: ws::Result<()>) {
        if let Err(error) = result {
            println!("🧦  {}: {}",
                Paint::default("Socket failed to start").bold().fg(Color::Red),
                error
            );
        } else {
            println!("🧦  {} {}",
                Paint::default("Socket is listening on").bold(),
                Paint::default(HOST.replace("127.0.0.1", "http://localhost")).bold().underline()
            );
        }
    }
}
