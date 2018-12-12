#![feature(proc_macro_hygiene, decl_macro)]

extern crate dotenv;
#[macro_use]
extern crate rocket;
extern crate ws;

#[macro_use]
extern crate serde_derive;
extern crate serde;
extern crate serde_json;

#[derive(Deserialize, Debug)]
struct Message<'a> {
    name: &'a str,
    data: Option<&'a str>
}

enum Error {
    SocketFailed(ws::Error),
    DecodeFailed(serde_json::Error)
}

fn decode<'a, T>(text: &'a str) -> Result<T, Error> where T: serde::Deserialize<'a> {
    serde_json::from_str(text).map_err(Error::DecodeFailed)
}

fn main() {
    dotenv::dotenv()
        .ok();

    // start websocket listener
    std::thread::spawn(|| {
        ws::listen("127.0.0.1:8080", |out| {
            move |msg: ws::Message| {
                let result = msg
                    .as_text()
                    .map_err(Error::SocketFailed)
                    .and_then(decode::<Message>);

                if let Ok(message) = result {
                    match message.name {
                        "STORY.JOIN" => out.send(ws::Message::text("joined")),
                        _ => Ok(())
                    }
                } else {
                    Ok(())
                }
            }
        })
    });

    // start rocket app
    rocket::ignite().mount("/", routes![]).launch();
}
