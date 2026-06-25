mod grid;
mod preview;
mod styles;

use iced::widget::{center, column, scrollable, text, text_input};
use iced::{Center, Element, Fill};

use crate::app::{Message, State, COLUMNS, SPACING};

use grid::emoji_cell;
use preview::preview_bar;
use styles::subtle;

pub fn main_view(state: &State) -> Element<'_, Message> {
    let search = text_input("Search emojis...", &state.query)
        .id(state.search_id.clone())
        .on_input(Message::SearchChanged)
        .padding(12)
        .size(20);

    let grid_content: Element<_> = if state.filtered.is_empty() {
        center(
            text("No emojis found")
                .width(Fill)
                .align_x(Center)
                .size(20)
                .style(subtle),
        )
        .height(200)
        .into()
    } else {
        let cells = state.filtered.iter().map(|&i| emoji_cell(state, i));

        iced::widget::grid(cells)
            .columns(COLUMNS)
            .spacing(SPACING)
            .height(iced::widget::grid::Sizing::AspectRatio(1.0))
            .into()
    };

    let scroll = scrollable(grid_content)
        .id(state.scroll_id.clone())
        .width(Fill)
        .height(Fill)
        .auto_scroll(true);

    let preview = preview_bar(state);

    column![search, scroll, preview]
        .spacing(12)
        .padding(12)
        .width(Fill)
        .height(Fill)
        .into()
}
