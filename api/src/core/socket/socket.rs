use super::channel::Channel;
use super::routes::Routes;
use crate::core::empty;
use yansi::{Color, Paint};

// constants
const HOST: &'static str = "127.0.0.1:8080";

// -- types --
pub struct Socket;

// -- impls --
impl Socket {
    // -- impls/commands
    pub fn listen<R>(&self, routes: R)
    where
        R: Routes + Clone,
    {
        info!(
            "🧦  {} {}",
            Paint::default("Socket is starting on").bold(),
            Paint::default(HOST.replace("127.0.0.1", "http://localhost"))
                .bold()
                .underline()
        );

        let finished = ws::WebSocket::new(Channel::new(routes))
            .and_then(|s| s.listen(HOST))
            .map(empty::ignore);

        self.on_finished(finished);
    }

    // -- impls/events
    fn on_finished(&self, result: ws::Result<()>) {
        if let Err(error) = result {
            error!(
                "🧦  {}: {}",
                Paint::default("Socket finished with error")
                    .bold()
                    .fg(Color::Red),
                error
            );
        } else {
            info!("🧦  {}", Paint::default("Socket finished").bold());
        }
    }
}
