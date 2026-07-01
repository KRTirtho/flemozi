use iced::widget::{button, container, sensor, space, text};
use iced::{border, Center, Color, Element, Fill};
use iced::font::Font;
use iced::widget::text::Shaping;

use crate::app::{Message, State};

pub fn emoji_cell<'a>(state: &'a State, i: usize) -> Element<'a, Message> {
    let entry = &state.emoji.entries[i];
    let is_selected = i == state.emoji.selected;
    let is_visible = state.emoji.visible.contains(&i);

    let cell: Element<_> = if is_visible {
        text(entry.emoji)
            .width(Fill)
            .height(Fill)
            .align_x(Center)
            .size(24)
            .font(Font::with_name("Noto Color Emoji"))
            .shaping(Shaping::Advanced)
            .into()
    } else {
        space().into()
    };

    let button = button(cell)
        .width(Fill)
        .height(Fill)
        .padding(4)
        .style(button::text)
        .on_press(Message::Selected(i));

    let styled: Element<_> = if is_selected && !state.search_focused {
        container(button)
            .style(move |_theme| container::Style {
                border: border::rounded(4)
                    .width(2.0)
                    .color(Color::from_rgb8(0x2e, 0x7d, 0x32)),
                ..container::Style::default()
            })
            .into()
    } else {
        button.into()
    };

    sensor(styled)
        .key(i)
        .on_show(move |_| Message::Shown(i))
        .into()
}
