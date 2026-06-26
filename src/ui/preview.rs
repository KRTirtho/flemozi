use iced::widget::{column, container, image, row, text};
use iced::{Alignment, ContentFit, Element, Fill, Pixels};

use crate::app::{Message, State};
use crate::emoji::to_codepoints;

use super::styles::{copied_style, preview_style, subtle};

pub fn preview_bar(state: &State) -> Element<'_, Message> {
    let (entry, is_copied) = match state.emoji.filtered.is_empty() {
        false => match state.emoji.entries.get(state.emoji.selected) {
            Some(e) => (e, state.copied.as_deref() == Some(e.emoji)),
            None => return empty_preview(),
        },
        true => return empty_preview(),
    };

    let icon: Element<_> = match &entry.image {
        Some(handle) => image(handle)
            .width(Pixels(48.0))
            .height(Pixels(48.0))
            .content_fit(ContentFit::Contain)
            .into(),
        None => text(entry.emoji).size(40).into(),
    };

    let description = text(entry.description).size(16);
    let codepoints = text(format!("{}  ·  U+{}", entry.emoji, to_codepoints(entry.emoji)))
        .size(12)
        .style(subtle);

    let info = column![description, codepoints].spacing(2);

    let status = if is_copied {
        text("Copied to clipboard!").size(13).style(copied_style)
    } else {
        text("Press Enter to copy").size(13).style(subtle)
    };

    container(
        row![icon, info, status]
            .spacing(12)
            .align_y(Alignment::Center)
            .width(Fill),
    )
    .padding(10)
    .style(preview_style)
    .into()
}

pub fn empty_preview() -> Element<'static, Message> {
    container(text(" ").size(16))
        .padding(10)
        .style(preview_style)
        .into()
}
