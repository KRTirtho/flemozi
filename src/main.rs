#![cfg_attr(target_os = "windows", windows_subsystem = "windows")]

mod app;
mod assets;
mod config;
mod emoji;
mod emoticon;
mod env;
mod search;
mod tabs;
mod twemoji_stems;
mod ui;
#[cfg(target_os = "windows")]
mod win32;
#[cfg(target_os = "macos")]
mod macos;

use app::Flemozi;

pub fn main() -> iced::Result {
    tracing_subscriber::fmt::init();

    #[cfg(target_os = "macos")]
    unsafe {
        macos::set_activation_policy_accessory();
    }

    application().run()
}

fn application() -> iced::Application<impl iced::Program<Message = app::Message, Theme = iced::Theme>> {
    use iced::window;

    let settings = window::Settings {
        size: iced::Size::new(500.0, 500.0),
        position: window::Position::Default,
        min_size: None,
        max_size: None,
        visible: false,
        resizable: false,
        closeable: false,
        minimizable: false,
        decorations: false,
        transparent: true,
        level: window::Level::AlwaysOnTop,
        ..Default::default()
    };

    iced::application(Flemozi::new, Flemozi::update, Flemozi::view)
        .subscription(Flemozi::subscription)
        .title(Flemozi::title)
        .window(settings)
        .exit_on_close_request(false)
}
