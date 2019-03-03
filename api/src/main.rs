#![allow(proc_macro_derive_resolution_fallback)]
#![feature(proc_macro_hygiene, decl_macro, custom_attribute)]

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
#[macro_use]
extern crate lazy_static;

// api
#[macro_use]
extern crate rocket;
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
use std::sync::Arc;
use core::socket;
use core::logger;

fn main() {
    logger::setup();
    dotenv::dotenv().ok();
    socket::listen(Arc::new(action::Routes));
    rocket::ignite().mount("/", routes![]).launch();
}
