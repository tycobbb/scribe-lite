#![feature(proc_macro_hygiene, decl_macro)]

extern crate dotenv;
#[macro_use]
extern crate rocket;
extern crate ws;

extern crate serde;
extern crate serde_json;
#[macro_use]
extern crate serde_derive;

mod action;
mod story;
mod socket;

fn main() {
    dotenv::dotenv().ok();
    socket::listen();
    rocket::ignite().mount("/", routes![]).launch();
}
