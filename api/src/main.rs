#![allow(proc_macro_derive_resolution_fallback)]

// crates
#[macro_use]
extern crate log;

#[macro_use]
extern crate diesel;

// modules
#[macro_use]
mod syntax;
mod action;
mod core;
mod domain;

// main
use crate::core::logger;
use crate::core::socket;

fn main() {
    logger::setup();
    dotenv::dotenv().ok();
    socket::listen(action::Routes);
}
