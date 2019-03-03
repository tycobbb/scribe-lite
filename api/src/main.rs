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
use std::io::Write;
use std::sync::Arc;
use core::socket;

fn main() {
    setup_logger();
    dotenv::dotenv().ok();
    socket::listen(Arc::new(action::Routes));
    rocket::ignite().mount("/", routes![]).launch();
}

fn setup_logger() {
    fn fmt_level<'a>(level: log::Level) -> &'a str {
        match level {
            log::Level::Error => "E",
            log::Level::Warn  => "W",
            log::Level::Info  => "I",
            log::Level::Debug => "D",
            log::Level::Trace => "T",
        }
    }

    fn fmt_module<'a>(module: Option<&'a str>) -> &'a str {
        module
            .and_then(|module| module.split("::").next())
            .unwrap_or("<?>")
    }

    let mut logs = env_logger::Builder::from_default_env();
    logs.format(|buf, record| {
        writeln!(buf, "[{}] {:<6} - {}",
            fmt_level(record.level()),
            fmt_module(record.module_path()),
            record.args()
        )
    });

    logs.init();
}
