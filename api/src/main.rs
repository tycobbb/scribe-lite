#![allow(proc_macro_derive_resolution_fallback)]

// logging
#[macro_use]
extern crate log;
extern crate env_logger;
extern crate yansi;

// core
extern crate dotenv;
extern crate chrono;
#[macro_use]
extern crate diesel;

// api
extern crate ws;

// serialization
extern crate serde;
extern crate serde_json;
#[macro_use]
extern crate serde_derive;

// modules
mod core;
mod domain;
mod action;

// main
use core::socket;
use core::logger;

fn main() {
    logger::setup();
    dotenv::dotenv().ok();
    socket::listen(action::Routes);
}
