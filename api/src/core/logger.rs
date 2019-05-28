use std::io::Write;

pub fn setup() {
    let mut logs = env_logger::Builder::from_default_env();
    logs.format(|buf, record| {
        writeln!(
            buf,
            "[{}] {:<6} - {}",
            format_level(record.level()),
            format_module(record.module_path()),
            record.args()
        )
    });

    logs.init();
}

fn format_level<'a>(level: log::Level) -> &'a str {
    match level {
        log::Level::Error => "E",
        log::Level::Warn => "W",
        log::Level::Info => "I",
        log::Level::Debug => "D",
        log::Level::Trace => "T",
    }
}

fn format_module<'a>(module: Option<&'a str>) -> &'a str {
    module
        .and_then(|module| module.split("::").next())
        .unwrap_or("<?>")
}
