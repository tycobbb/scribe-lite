use std::sync::{ Mutex, MutexGuard };
use super::Queue;

// types
pub struct Repo;

// impls
lazy_static! {
    static ref QUEUE: Mutex<Queue> = Mutex::new(Queue::new());
}

impl Repo {
    pub fn find_for_today(&self) -> MutexGuard<Queue> {
        QUEUE.lock().unwrap()
    }
}
