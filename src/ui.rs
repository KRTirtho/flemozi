mod grid;
mod preview;
mod styles;

use iced::widget::{button, center, column, container, row, scrollable, space, text};
use iced::{Alignment, Center, Element, Fill};

use crate::app::{Message, State, Tab, COLUMNS, SPACING};

use grid::emoji_cell;
use preview::preview_bar;
use styles::{search_bar_active_style, search_bar_inactive_style, selected_text_style, sidebar_active_style, sidebar_inactive_style, subtle};

pub fn main_view(state: &State) -> Element<'_, Message> {
    let titlebar = titlebar_view();
    let sidebar = sidebar_view(state);
    let content: Element<'_, Message> = if state.tab == Tab::Emojis {
        emoji_view(state)
    } else {
        settings_view()
    };

    column![
        titlebar,
        row![sidebar, content]
            .spacing(0)
            .width(Fill)
            .height(Fill),
    ]
    .spacing(0)
    .width(Fill)
    .height(Fill)
    .into()
}

fn titlebar_view() -> Element<'static, Message> {
    let close_btn = button(text("\u{00d7}").size(16))
        .on_press(Message::TitleBarClose)
        .style(button::text)
        .padding(2);

    row![
        text("Flemozi").size(14),
        space::horizontal(),
        close_btn,
    ]
    .padding([0, 8])
    .align_y(Alignment::Center)
    .height(20)
    .into()
}

fn sidebar_view(state: &State) -> Element<'_, Message> {
    let emoji_icon = container(text("\u{2630}").size(16))
        .align_x(Center)
        .align_y(Center)
        .width(Fill)
        .height(Fill);

    let settings_icon = container(text("\u{2699}").size(16))
        .align_x(Center)
        .align_y(Center)
        .width(Fill)
        .height(Fill);

    let emoji_btn = button(emoji_icon)
        .on_press(Message::TabSelected(Tab::Emojis))
        .style(if state.tab == Tab::Emojis {
            sidebar_active_style
        } else {
            sidebar_inactive_style
        })
        .width(42)
        .height(42)
        .padding(0);

    let settings_btn = button(settings_icon)
        .on_press(Message::TabSelected(Tab::Settings))
        .style(if state.tab == Tab::Settings {
            sidebar_active_style
        } else {
            sidebar_inactive_style
        })
        .width(42)
        .height(42)
        .padding(0);

    column![emoji_btn, settings_btn, space::vertical()]
        .spacing(0)
        .width(42)
        .height(Fill)
        .align_x(Center)
        .into()
}

fn emoji_view(state: &State) -> Element<'_, Message> {
    let content: Element<'_, Message> = if state.query.is_empty() {
        text("Search emojis...")
            .size(20)
            .style(subtle)
            .into()
    } else if let Some((a, b)) = state.selection {
        let lo = a.min(b);
        let hi = a.max(b);
        let before = &state.query[..lo];
        let selected = &state.query[lo..hi];
        let after = &state.query[hi..];
        row![
            text(before).size(20),
            container(text(selected).size(20)).style(selected_text_style),
            text(after).size(20),
        ]
        .into()
    } else if state.search_focused {
        let before = &state.query[..state.cursor];
        let after = &state.query[state.cursor..];
        row![
            text(before).size(20),
            text("|").size(20),
            text(after).size(20),
        ]
        .into()
    } else {
        text(&state.query).size(20).into()
    };
    let search = container(content)
        .padding(12)
        .width(Fill)
        .style(if state.search_focused {
            search_bar_active_style
        } else {
            search_bar_inactive_style
        });

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

fn settings_view() -> Element<'static, Message> {
    container(
        column![
            text("Flemozi Emoji Picker").size(20),
            text("Version 0.1.0").size(14).style(subtle),
            text("").size(8),
            text("Keyboard Shortcuts:").size(16),
            text("  Ctrl+Alt+.  - Toggle window").size(14).style(subtle),
            text("  Escape      - Clear search").size(14).style(subtle),
            text("  Enter       - Copy emoji").size(14).style(subtle),
            text("  Arrows      - Navigate").size(14).style(subtle),
        ]
        .spacing(4)
        .padding(20),
    )
    .width(Fill)
    .height(Fill)
    .into()
}
