use iced::widget::{button, image, sensor, space, text};
use iced::{Center, ContentFit, Element, Fill};

use crate::app::{Message, State};

pub fn emoji_cell<'a>(state: &'a State, i: usize) -> Element<'a, Message> {
    let entry = &state.entries[i];
    let is_selected = i == state.selected;
    let is_visible = state.visible.contains(&i);

    let cell: Element<_> = if is_visible {
        match &entry.image {
            Some(handle) => image(handle)
                .width(Fill)
                .height(Fill)
                .content_fit(ContentFit::Contain)
                .into(),
            None => text(entry.emoji)
                .width(Fill)
                .height(Fill)
                .align_x(Center)
                .size(24)
                .into(),
        }
    } else {
        space().into()
    };

    let button = button(cell)
        .width(Fill)
        .height(Fill)
        .padding(4)
        .style(if is_selected {
            button::primary
        } else {
            button::text
        })
        .on_press(Message::Selected(i));

    sensor(button)
        .on_show(move |_| Message::Shown(i))
        .on_hide(Message::Hidden(i))
        .into()
}
