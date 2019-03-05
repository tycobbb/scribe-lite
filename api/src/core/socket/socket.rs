use std::sync::Arc;
use yansi::{ Paint, Color };
use super::routes::Routes;
use super::channel::Channel;

// constants
const HOST: &'static str = "127.0.0.1:8080";

// types
pub struct Socket;

// impls
impl Socket {
    pub fn listen(&self, routes: Arc<Routes>) {
        info!("🧦  {} {}",
            Paint::default("Socket is starting on").bold(),
            Paint::default(HOST.replace("127.0.0.1", "http://localhost")).bold().underline()
        );

        let result = ws::WebSocket::new(Channel::new(routes))
            .and_then(|s| s.listen(HOST))
            .map(|_| ());

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
