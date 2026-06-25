mod app;
mod assets;
mod emoji;
mod search;
mod twemoji_stems;
mod ui;
mod win32;

use app::Flemozi;

pub fn main() -> iced::Result {
    tracing_subscriber::fmt::init();

    application().run()
}

fn application() -> iced::Application<impl iced::Program<Message = app::Message, Theme = iced::Theme>> {
    iced::application(Flemozi::new, Flemozi::update, Flemozi::view)
        .subscription(Flemozi::subscription)
        .title(Flemozi::title)
        .window_size((500.0, 800.0))
        .decorations(false)
        .exit_on_close_request(false)
        .resizable(false)
}
