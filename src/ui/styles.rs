use iced::widget::{container, text};
use iced::{Background, Color, Theme};

pub fn subtle(theme: &Theme) -> text::Style {
    text::Style {
        color: Some(theme.palette().text.scale_alpha(0.5)),
    }
}

pub fn copied_style(_theme: &Theme) -> text::Style {
    text::Style {
        color: Some(Color::from_rgb8(0x2e, 0x7d, 0x32)),
    }
}

pub fn preview_style(theme: &Theme) -> container::Style {
    let pair = theme.extended_palette().background.weak;

    container::Style {
        background: Some(Background::from(pair.color)),
        border: iced::border::rounded(8),
        text_color: Some(pair.text),
        ..container::Style::default()
    }
}
