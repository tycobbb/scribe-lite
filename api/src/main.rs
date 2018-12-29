#![feature(proc_macro_hygiene, decl_macro)]

extern crate dotenv;
#[macro_use]
extern crate rocket;
extern crate ws;

extern crate serde;
extern crate serde_json;
#[macro_use]
extern crate serde_derive;

mod core;
mod action;

use core::socket as socket;

fn main() {
    dotenv::dotenv().ok();
    socket::listen(&action::Routes);
    rocket::ignite().mount("/", routes![]).launch();
}
