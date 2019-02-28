use std::sync::Arc;
use yansi::{ Paint, Color };
use super::routes::Routes;
use super::channel::Channel;
use super::connection::Connection;

// constants
const HOST: &'static str = "127.0.0.1:8080";

// types
pub struct Socket;

// impls
impl Socket {
    pub fn listen(&self, routes: Arc<Routes>) {
        info!("🧦  {} {}",
            Paint::default("Socket is listening on").bold(),
            Paint::default(HOST.replace("127.0.0.1", "http://localhost")).bold().underline()
        );

        let result = ws::listen(HOST, |out| {
            let channel = Arc::new(Channel::new(out));
            let routes  = routes.clone();

            move |msg: ws::Message| {
                let connection = Connection::new(routes.clone(), channel.clone());
                connection.handle(msg);
                Ok(())
            }
        });

        self.notify(result);
    }

    fn notify(&self, result: ws::Result<()>) {
        if let Err(error) = result {
            error!("🧦  {}: {}",
                Paint::default("Socket finished with error").bold().fg(Color::Red),
                error
            );
        } else {
            info!("🧦  {}",
                Paint::default("Socket finished").bold()
            );
        }
    }
}
