use iced::widget::{button, container, text};
use iced::{Background, Color, Theme, border};

pub fn selected_text_style(theme: &Theme) -> container::Style {
    let palette = theme.extended_palette().background;
    let accent = palette.strong.color;
    container::Style {
        background: Some(Background::Color(accent)),
        text_color: Some(palette.strong.text),
        ..container::Style::default()
    }
}

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

pub fn sidebar_active_style(theme: &Theme, _status: button::Status) -> button::Style {
    let palette = theme.extended_palette().background;
    button::Style {
        background: Some(Background::Color(palette.weak.color)),
        text_color: palette.weak.text,
        ..button::Style::default()
    }
}

pub fn search_bar_style(theme: &Theme) -> container::Style {
    let pair = theme.extended_palette().background.weak;

    container::Style {
        background: Some(Background::from(pair.color)),
        border: border::rounded(8).width(2.0).color(Color::from_rgb8(0x2e, 0x7d, 0x32)),
        text_color: Some(pair.text),
        ..container::Style::default()
    }
}

pub fn sidebar_inactive_style(theme: &Theme, status: button::Status) -> button::Style {
    let bg = match status {
        button::Status::Hovered => Some(Background::Color(
            theme.palette().background.scale_alpha(0.3),
        )),
        _ => None,
    };
    button::Style {
        background: bg,
        border: border::rounded(0),
        text_color: theme.palette().text,
        ..button::Style::default()
    }
}
