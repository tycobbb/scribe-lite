use socket;
use socket::{ EventIn, MessageIn };
use actions::story;

// types
pub struct Routes;

// impls
impl socket::Routes for Routes {
    fn resolve(&self, msg: MessageIn) -> socket::Result<String> {
        match msg.name {
            EventIn::StoryJoin    => msg.resolve(&story::Join),
            EventIn::StoryAddLine => msg.resolve(&story::AddLine)
        }
    }
}
