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
struct Message<'a, T> {
    name: &'a str,
    data: T
}

#[derive(Serialize, Debug)]
struct Response<'a, T> {
    name: &'a str,
    #[serde(flatten)]
    payload: Payload<'a, T>
}

#[derive(Serialize, Debug)]
#[serde(rename_all="lowercase")]
enum Payload<'a, T> {
    Data(T),
    Error(Errors<'a>)
}

#[derive(Serialize, Debug)]
struct Errors<'a> {
    messages: &'a str
}

#[derive(Serialize, Debug)]
struct JoinDone<'a> {
    text: &'a str,
    name: &'a str
}

enum Error {
    SocketFailed(ws::Error),
    DecodeFailed(serde_json::Error),
}

fn decode<'a, T>(text: &'a str) -> Result<Message<'a, T>, Error> where T: serde::Deserialize<'a> {
    serde_json::from_str(text).map_err(Error::DecodeFailed)
}

fn encode<'a, T>(response: Response<'a, T>) -> String where T: serde::Serialize {
    serde_json::to_string(&response)
        .unwrap_or_else(|_| { encode_error(response) })
}

fn encode_error<'a, T>(original: Response<'a, T>) -> String where T: serde::Serialize {
    let message = Response::<T> {
        name:    original.name,
        payload: Payload::Error(Errors {
            messages: "Encoding error."
        })
    };

    serde_json::to_string(&message).unwrap()
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
                    .and_then(decode::<serde::de::IgnoredAny>);

                if let Ok(message) = result {
                    match message.name {
                        "STORY.JOIN" => out.send(ws::Message::text(encode(Response {
                            name:    "STORY.JOIN.DONE",
                            payload: Payload::Data(JoinDone {
                                name: "This is the first line.",
                                text: "Mr. Socket"
                            })
                        }))),
                        "STORY.ADD_LINE" => out.send(ws::Message::text(encode(Response {
                            name: "STORY.ADD_LINE.DONE",
                            payload: Payload::Data::<Option<&str>>(None)
                        }))),
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
