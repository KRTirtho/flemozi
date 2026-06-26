mod grid;
mod preview;
mod styles;

use iced::widget::{button, center, column, container, row, scrollable, sensor, space, text, toggler};
use iced::{Alignment, Center, Color, ContentFit, Element, Fill, border};

use crate::app::{shortcut_display_name, Message, State, Tab, COLUMNS, SPACING};

use grid::emoji_cell;
use preview::{preview_bar, empty_preview as preview_empty};
use styles::{copied_style, preview_style, search_bar_active_style, search_bar_inactive_style, selected_text_style, sidebar_active_style, sidebar_inactive_style, subtle};

pub fn main_view(state: &State) -> Element<'_, Message> {
    let titlebar = titlebar_view();
    let sidebar = sidebar_view(state);
    let content: Element<'_, Message> = match state.tab {
        Tab::Emojis => emoji_view(state),
        Tab::Emoticons => emoticons_view(state),
        Tab::Gifs => gif_view(state),
        Tab::Settings => settings_view(state),
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

    let emoticon_icon = container(text("\u{263a}").size(16))
        .align_x(Center)
        .align_y(Center)
        .width(Fill)
        .height(Fill);

    let gif_icon = container(text("GIF").size(13))
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

    let emoticon_btn = button(emoticon_icon)
        .on_press(Message::TabSelected(Tab::Emoticons))
        .style(if state.tab == Tab::Emoticons {
            sidebar_active_style
        } else {
            sidebar_inactive_style
        })
        .width(42)
        .height(42)
        .padding(0);

    let gif_btn = button(gif_icon)
        .on_press(Message::TabSelected(Tab::Gifs))
        .style(if state.tab == Tab::Gifs {
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

    column![emoji_btn, emoticon_btn, gif_btn, settings_btn, space::vertical()]
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

    let grid_content: Element<_> = if state.emoji.filtered.is_empty() {
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
        let cells = state.emoji.filtered.iter().map(|&i| emoji_cell(state, i));

        iced::widget::grid(cells)
            .columns(COLUMNS)
            .spacing(SPACING)
            .height(iced::widget::grid::Sizing::AspectRatio(1.0))
            .into()
    };

    let scroll = scrollable(grid_content)
        .id(state.emoji.scroll_id.clone())
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

fn emoticon_cell(state: &State, i: usize) -> Element<'_, Message> {
    let entry = &state.emoticon.entries[i];
    let is_selected = i == state.emoticon.selected;

    let cell = text(entry.text)
        .size(13)
        .width(Fill)
        .height(Fill)
        .align_x(Center)
        .align_y(Center);

    let btn = button(cell)
        .width(Fill)
        .height(Fill)
        .padding(4)
        .style(button::text)
        .on_press(Message::Selected(i));

    if is_selected && !state.search_focused {
        container(btn)
            .style(move |_theme| container::Style {
                border: border::rounded(4)
                    .width(2.0)
                    .color(Color::from_rgb8(0x2e, 0x7d, 0x32)),
                ..container::Style::default()
            })
            .into()
    } else {
        btn.into()
    }
}

fn emoticon_preview(state: &State) -> Element<'_, Message> {
    let (entry, is_copied) = match state.emoticon.filtered.is_empty() {
        false => match state.emoticon.entries.get(state.emoticon.selected) {
            Some(e) => (
                e,
                state.copied.as_deref() == Some(e.text),
            ),
            None => return preview_empty(),
        },
        true => return preview_empty(),
    };

    let text_display = text(entry.text).size(18);

    let category = text(entry.category).size(12).style(subtle);

    let info = column![text_display, category].spacing(2);

    let status = if is_copied {
        text("Copied to clipboard!").size(13).style(copied_style)
    } else {
        text("Press Enter to copy").size(13).style(subtle)
    };

    container(
        row![info, status]
            .spacing(12)
            .align_y(Alignment::Center)
            .width(Fill),
    )
    .padding(10)
    .style(preview_style)
    .into()
}

fn emoticons_view(state: &State) -> Element<'_, Message> {
    let content: Element<'_, Message> = if state.query.is_empty() {
        text("Search emoticons...")
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

    let grid_content: Element<_> = if state.emoticon.filtered.is_empty() {
        center(
            text("No emoticons found")
                .width(Fill)
                .align_x(Center)
                .size(20)
                .style(subtle),
        )
        .height(200)
        .into()
    } else {
        let cells = state
            .emoticon
            .filtered
            .iter()
            .map(|&i| emoticon_cell(state, i));

        iced::widget::grid(cells)
            .columns(COLUMNS)
            .spacing(SPACING)
            .height(iced::widget::grid::Sizing::AspectRatio(1.0))
            .into()
    };

    let scroll = scrollable(grid_content)
        .id(state.emoticon.scroll_id.clone())
        .width(Fill)
        .height(Fill)
        .auto_scroll(true);

    let preview = emoticon_preview(state);

    column![search, scroll, preview]
        .spacing(12)
        .padding(12)
        .width(Fill)
        .height(Fill)
        .into()
}

fn gif_cell(state: &State, i: usize) -> Element<'_, Message> {
    let is_visible = state.gif.visible.contains(&i);
    let has_frames = state.gif.frames.contains_key(&i);
    let is_selected = i == state.gif.selected;

    let cell: Element<_> = if is_visible && has_frames {
        iced_gif::gif(state.gif.frames.get(&i).unwrap())
            .width(Fill)
            .height(Fill)
            .content_fit(ContentFit::Contain)
            .into()
    } else if is_visible {
        text("GIF")
            .size(10)
            .width(Fill)
            .height(Fill)
            .align_x(Center)
            .align_y(Center)
            .style(subtle)
            .into()
    } else {
        space().into()
    };

    let btn = button(cell)
        .width(Fill)
        .height(Fill)
        .padding(4)
        .style(button::text)
        .on_press(Message::Selected(i));

    let styled: Element<_> = if is_selected && !state.search_focused {
        container(btn)
            .style(move |_theme| container::Style {
                border: border::rounded(4)
                    .width(2.0)
                    .color(Color::from_rgb8(0x2e, 0x7d, 0x32)),
                ..container::Style::default()
            })
            .into()
    } else {
        btn.into()
    };

    sensor(styled)
        .key(i)
        .on_show(move |_| Message::Shown(i))
        .into()
}

fn gif_preview(state: &State) -> Element<'_, Message> {
    let (entry, is_copied) = match state.gif.filtered.is_empty() {
        false => match state.gif.entries.get(state.gif.selected) {
            Some(e) => (
                e,
                state.copied.as_deref() == Some(&e.url),
            ),
            None => return preview_empty(),
        },
        true => return preview_empty(),
    };

    let slug = &entry.slug;
    let title_display = text(slug).size(16);

    let rating = text(format!("Rating: {}", entry.rating.to_uppercase()))
        .size(12)
        .style(subtle);

    let info = column![title_display, rating].spacing(2);

    let status = if is_copied {
        text("Copied to clipboard!").size(13).style(copied_style)
    } else {
        text("Press Enter to copy URL").size(13).style(subtle)
    };

    container(
        row![info, status]
            .spacing(12)
            .align_y(Alignment::Center)
            .width(Fill),
    )
    .padding(10)
    .style(preview_style)
    .into()
}

fn gif_view(state: &State) -> Element<'_, Message> {
    let content: Element<'_, Message> = if state.query.is_empty() {
        text("Search GIFs...")
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

    let grid_content: Element<_> = if let Some(ref err) = state.gif.error {
        center(
            text(format!("Giphy error: {err}"))
                .width(Fill)
                .align_x(Center)
                .size(16)
                .style(subtle),
        )
        .height(200)
        .into()
    } else if state.gif.loading {
        center(
            text("Loading GIFs...")
                .width(Fill)
                .align_x(Center)
                .size(20)
                .style(subtle),
        )
        .height(200)
        .into()
    } else if state.gif.filtered.is_empty() {
        center(
            text("No GIFs found")
                .width(Fill)
                .align_x(Center)
                .size(20)
                .style(subtle),
        )
        .height(200)
        .into()
    } else {
        let cells = state
            .gif
            .filtered
            .iter()
            .map(|&i| gif_cell(state, i));

        iced::widget::grid(cells)
            .columns(2)
            .spacing(SPACING)
            .height(iced::widget::grid::Sizing::AspectRatio(1.0))
            .into()
    };

    let scroll = scrollable(grid_content)
        .id(state.gif.scroll_id.clone())
        .width(Fill)
        .height(Fill)
        .auto_scroll(true);

    let preview = gif_preview(state);

    column![search, scroll, preview]
        .spacing(12)
        .padding(12)
        .width(Fill)
        .height(Fill)
        .into()
}

fn settings_view(state: &State) -> Element<'_, Message> {
    let launch_toggle = toggler(state.config.launch_at_startup)
        .label("Launch at startup")
        .on_toggle(|_| Message::ToggleLaunchAtStartup)
        .size(20)
        .spacing(8);

    let shortcut_label = if state.capturing_shortcut {
        "Press shortcut...".to_string()
    } else {
        shortcut_display_name(&state.config)
    };
    let shortcut_header = text("Global shortcut:").size(16);
    let shortcut_text = text(shortcut_label).size(14).style(subtle);
    let record_btn = if state.capturing_shortcut {
        button(text("Cancel").size(14))
            .on_press(Message::ToggleCaptureShortcut)
            .style(button::text)
            .padding(8)
    } else {
        button(text("Record").size(14))
            .on_press(Message::ToggleCaptureShortcut)
            .style(button::text)
            .padding(8)
    };

    container(
        column![
            text("Flemozi Emoji Picker").size(20),
            text("Version 0.1.0").size(14).style(subtle),
            space::vertical().height(12),
            launch_toggle,
            space::vertical().height(12),
            shortcut_header,
            row![shortcut_text, record_btn].spacing(8).align_y(Alignment::Center),
            space::vertical().height(12),
            text("Keyboard shortcuts:").size(16),
            text("  Escape      - Clear search (when empty, close)")
                .size(14)
                .style(subtle),
            text("  Enter       - Copy emoji").size(14).style(subtle),
            text("  Arrows      - Navigate emojis").size(14).style(subtle),
        ]
        .spacing(4)
        .padding(20),
    )
    .width(Fill)
    .height(Fill)
    .into()
}
