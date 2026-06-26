use std::collections::HashSet;

use iced::widget::{self, operation, scrollable};
use iced::Task as Command;

use crate::app::{Message, Move, SearchState, COLUMNS, SPACING};
use crate::assets::emojis::EMOJIS;
use crate::emoji::EmojiEntry;
use crate::search::filter;

fn move_in(filtered: &[usize], selected: &mut usize, mv: Move) -> bool {
    if filtered.is_empty() {
        return false;
    }

    let pos = filtered.iter().position(|&i| i == *selected).unwrap_or(0);
    let len = filtered.len();
    let next = match mv {
        Move::Up => pos.saturating_sub(COLUMNS),
        Move::Down => (pos + COLUMNS).min(len - 1),
        Move::Left => pos.saturating_sub(1),
        Move::Right => (pos + 1).min(len - 1),
    };

    let old_row = pos / COLUMNS;
    let new_row = next / COLUMNS;
    *selected = filtered[next];
    old_row != new_row
}

fn scroll_y(filtered: &[usize], selected: usize) -> f32 {
    let pos = filtered.iter().position(|&i| i == selected).unwrap_or(0);
    let row = pos / COLUMNS;
    let content_width = 500.0 - 42.0 - 24.0;
    let gaps = (COLUMNS - 1) as f32 * SPACING;
    let cell_width = (content_width - gaps) / COLUMNS as f32;
    let row_height = cell_width + SPACING;
    row as f32 * row_height
}

pub struct EmojiTab {
    pub entries: Vec<EmojiEntry>,
    pub filtered: Vec<usize>,
    pub selected: usize,
    pub visible: HashSet<usize>,
    pub scroll_id: widget::Id,
    pub saved_search: SearchState,
}

impl EmojiTab {
    pub fn new() -> Self {
        let entries: Vec<EmojiEntry> = EMOJIS.iter().map(EmojiEntry::from_type).collect();
        let filtered = (0..entries.len()).collect();
        Self {
            entries,
            filtered,
            selected: 0,
            visible: HashSet::new(),
            scroll_id: "emoji-scroll".into(),
            saved_search: SearchState::new(),
        }
    }

    pub fn apply_search(&mut self, query: &str) {
        self.filtered = filter(&self.entries, query);
        self.selected = self.filtered.first().copied().unwrap_or(0);
    }

    pub fn reset_search(&mut self) {
        self.filtered = (0..self.entries.len()).collect();
        self.selected = self.filtered.first().copied().unwrap_or(0);
    }

    pub fn move_selection(&mut self, mv: Move) -> bool {
        move_in(&self.filtered, &mut self.selected, mv)
    }

    pub fn scroll_to_selected(&self) -> Command<Message> {
        if self.filtered.is_empty() {
            return Command::none();
        }
        let y = scroll_y(&self.filtered, self.selected);
        operation::scroll_to(
            self.scroll_id.clone(),
            scrollable::AbsoluteOffset { x: 0.0, y },
        )
    }

    pub fn copy_text(&self) -> Option<String> {
        let entry = self.entries.get(self.selected)?;
        if !self.filtered.contains(&self.selected) {
            return None;
        }
        Some(entry.emoji.to_owned())
    }
}
