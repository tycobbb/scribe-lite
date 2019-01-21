#![allow(proc_macro_derive_resolution_fallback)]
#![feature(proc_macro_hygiene, decl_macro, custom_attribute)]

extern crate yansi;

extern crate dotenv;
extern crate chrono;
#[macro_use]
extern crate diesel;
#[macro_use]
extern crate rocket;
extern crate ws;

extern crate serde;
extern crate serde_json;
#[macro_use]
extern crate serde_derive;

mod core;
mod domain;
mod action;

use core::socket as socket;

fn main() {
    dotenv::dotenv().ok();
    socket::listen(&action::Routes);
    rocket::ignite().mount("/", routes![]).launch();
}
