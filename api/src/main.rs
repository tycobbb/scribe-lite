#![feature(proc_macro_hygiene, decl_macro)]

extern crate dotenv;
#[macro_use]
extern crate rocket;
extern crate ws;

fn main() {
    dotenv::dotenv()
        .ok();

    // start websocket listener
    std::thread::spawn(|| {
        ws::listen("127.0.0.1:8080", |out| {
            move |msg| {
                out.send(msg)
            }
        })
    });

    // start rocket app
    rocket::ignite().mount("/", routes![]).launch();
}
