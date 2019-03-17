#![allow(proc_macro_derive_resolution_fallback)]

// crates
#[macro_use]
extern crate log;

#[macro_use]
extern crate diesel;

// modules
mod core;
mod domain;
mod action;

// main
use crate::core::socket;
use crate::core::logger;

fn main() {
    logger::setup();
    dotenv::dotenv().ok();
    socket::listen(action::Routes);
}
