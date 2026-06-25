use std::collections::HashSet;

use iced::event;
use iced::keyboard;
use iced::widget::{self, operation, scrollable};
use iced::{clipboard, Element, Subscription, Task as Command};

use crate::assets::emojis::EMOJIS;
use crate::emoji::EmojiEntry;
use crate::search::filter;
use crate::ui::main_view;

pub(crate) const COLUMNS: usize = 10;
pub(crate) const SPACING: f32 = 4.0;

#[derive(Debug)]
pub enum Flemozi {
    Loaded(State),
}

#[derive(Debug, Clone)]
pub struct State {
    pub query: String,
    pub entries: Vec<EmojiEntry>,
    pub filtered: Vec<usize>,
    pub selected: usize,
    pub copied: Option<String>,
    pub visible: HashSet<usize>,
    pub search_id: widget::Id,
    pub scroll_id: widget::Id,
}

#[derive(Debug, Clone)]
pub enum Message {
    SearchChanged(String),
    Selected(usize),
    MoveSelection(Move),
    CopySelected,
    ClearSearch,
    Shown(usize),
}

#[derive(Debug, Clone, Copy)]
pub enum Move {
    Up,
    Down,
    Left,
    Right,
}

impl Flemozi {
    pub fn new() -> (Self, Command<Message>) {
        let entries: Vec<EmojiEntry> = EMOJIS.iter().map(EmojiEntry::from_type).collect();
        let filtered = (0..entries.len()).collect();

        let state = State {
            entries,
            filtered,
            selected: 0,
            copied: None,
            query: String::new(),
            visible: HashSet::new(),
            search_id: "search".into(),
            scroll_id: "grid-scroll".into(),
        };

        (Self::Loaded(state), operation::focus("search"))
    }

    pub fn title(&self) -> String {
        "Flemozi".to_owned()
    }

    pub fn update(&mut self, message: Message) -> Command<Message> {
        let Flemozi::Loaded(state) = self;

        match message {
            Message::SearchChanged(query) => {
                state.query = query;
                state.filtered = filter(&state.entries, &state.query);
                state.selected = state.filtered.first().copied().unwrap_or(0);
                operation::scroll_to(
                    state.scroll_id.clone(),
                    scrollable::AbsoluteOffset { x: 0.0, y: 0.0 },
                )
            }
            Message::Selected(i) => {
                if state.filtered.contains(&i) {
                    state.selected = i;
                    state.copy()
                } else {
                    Command::none()
                }
            }
            Message::MoveSelection(mv) => {
                if state.move_selection(mv) {
                    state.scroll_to_selected()
                } else {
                    Command::none()
                }
            }
            Message::CopySelected => state.copy(),
            Message::ClearSearch => {
                state.query.clear();
                state.filtered = (0..state.entries.len()).collect();
                state.selected = state.filtered.first().copied().unwrap_or(0);
                Command::batch([
                    operation::scroll_to(
                        state.scroll_id.clone(),
                        scrollable::AbsoluteOffset { x: 0.0, y: 0.0 },
                    ),
                    operation::focus(state.search_id.clone()),
                ])
            }
            Message::Shown(i) => {
                state.visible.insert(i);
                Command::none()
            }
        }
    }

    pub fn view(&self) -> Element<'_, Message> {
        let Flemozi::Loaded(state) = self;
        main_view(state)
    }

    pub fn subscription(&self) -> Subscription<Message> {
        use keyboard::key;

        event::listen_raw(|event, _status, _window| {
            let event::Event::Keyboard(event) = event else {
                return None;
            };

            let keyboard::Event::KeyPressed {
                key: keyboard::Key::Named(key),
                ..
            } = event
            else {
                return None;
            };

            match key {
                key::Named::ArrowUp => Some(Message::MoveSelection(Move::Up)),
                key::Named::ArrowDown => Some(Message::MoveSelection(Move::Down)),
                key::Named::ArrowLeft => Some(Message::MoveSelection(Move::Left)),
                key::Named::ArrowRight => Some(Message::MoveSelection(Move::Right)),
                key::Named::Enter => Some(Message::CopySelected),
                key::Named::Escape => Some(Message::ClearSearch),
                _ => None,
            }
        })
    }
}

impl State {
    fn move_selection(&mut self, mv: Move) -> bool {
        if self.filtered.is_empty() {
            return false;
        }

        let pos = self
            .filtered
            .iter()
            .position(|&i| i == self.selected)
            .unwrap_or(0);

        let len = self.filtered.len();
        let next = match mv {
            Move::Up => pos.saturating_sub(COLUMNS),
            Move::Down => (pos + COLUMNS).min(len - 1),
            Move::Left => pos.saturating_sub(1),
            Move::Right => (pos + 1).min(len - 1),
        };

        let old_row = pos / COLUMNS;
        let new_row = next / COLUMNS;

        self.selected = self.filtered[next];

        old_row != new_row
    }

    fn scroll_to_selected(&self) -> Command<Message> {
        if self.filtered.is_empty() {
            return Command::none();
        }

        let pos = self
            .filtered
            .iter()
            .position(|&i| i == self.selected)
            .unwrap_or(0);

        let row = pos / COLUMNS;
        let cell_width = (500.0 - 24.0 - (COLUMNS - 1) as f32 * SPACING) / COLUMNS as f32;
        let row_height = cell_width + SPACING;
        let y = row as f32 * row_height;

        operation::scroll_to(
            self.scroll_id.clone(),
            scrollable::AbsoluteOffset { x: 0.0, y },
        )
    }

    fn copy(&mut self) -> Command<Message> {
        let Some(entry) = self.entries.get(self.selected) else {
            return Command::none();
        };

        if !self.filtered.contains(&self.selected) {
            return Command::none();
        }

        let emoji = entry.emoji.to_owned();
        self.copied = Some(emoji.clone());

        clipboard::write::<Message>(emoji)
    }
}
