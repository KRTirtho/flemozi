use std::collections::HashSet;
use std::sync::Mutex;

use iced::event;
use iced::keyboard;
use iced::mouse;
use iced::stream;
use iced::widget::{self, operation, scrollable};
use iced::{clipboard, window, Element, Point, Subscription, Task as Command};
use global_hotkey::hotkey::{Code, HotKey, Modifiers};
use global_hotkey::{GlobalHotKeyEvent, GlobalHotKeyManager};
use tray_icon::menu::{Menu, MenuEvent, MenuId, MenuItem, PredefinedMenuItem};
use tray_icon::TrayIconBuilder;

use crate::assets::emojis::EMOJIS;
use crate::emoji::EmojiEntry;
use crate::search::filter;
use crate::ui::main_view;
use crate::win32::HookKeyEvent;

pub(crate) const COLUMNS: usize = 10;
pub(crate) const SPACING: f32 = 4.0;

static LAST_CURSOR: Mutex<Option<Point>> = Mutex::new(None);
static LOGO_BYTES: &[u8] = include_bytes!("../assets/logo.png");

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum Tab {
    Emojis,
    Settings,
}

pub enum Flemozi {
    Loaded(State),
}

pub struct State {
    pub query: String,
    pub cursor: usize,
    pub selection: Option<(usize, usize)>,
    pub entries: Vec<EmojiEntry>,
    pub filtered: Vec<usize>,
    pub selected: usize,
    pub copied: Option<String>,
    pub visible: HashSet<usize>,
    pub scroll_id: widget::Id,
    pub tab: Tab,
    pub window_id: Option<window::Id>,
    pub our_hwnd: Option<isize>,
    pub last_foreground: Option<isize>,
}

#[derive(Debug, Clone)]
pub enum Message {
    Selected(usize),
    MoveSelection(Move),
    CopySelected,
    ClearSearch,
    Shown(usize),
    TabSelected(Tab),
    TitleBarDrag,
    TitleBarClose,
    HotkeyPressed(GlobalHotKeyEvent),
    MenuActivated(MenuEvent),
    Init(Option<window::Id>),
    Setup(isize),
    DoType(String),
    HookKeyEvent(HookKeyEvent),
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
            cursor: 0,
            selection: None,
            visible: HashSet::new(),
            scroll_id: "grid-scroll".into(),
            tab: Tab::Emojis,
            window_id: None,
            our_hwnd: None,
            last_foreground: None,
        };

        let cmd = window::latest().map(Message::Init);

        (Self::Loaded(state), cmd)
    }

    pub fn title(&self) -> String {
        "Flemozi".to_owned()
    }

    pub fn update(&mut self, message: Message) -> Command<Message> {
        let Flemozi::Loaded(state) = self;

        match message {
            Message::Init(id) => {
                state.window_id = id;
                if let Some(wid) = id {
                    return window::run(wid, |w| {
                        let hwnd = w
                            .window_handle()
                            .ok()
                            .and_then(|h| match h.as_raw() {
                                raw_window_handle::RawWindowHandle::Win32(h) => {
                                    Some(h.hwnd.get() as isize)
                                }
                                _ => None,
                            })
                            .unwrap_or(0);
                        Message::Setup(hwnd)
                    });
                }
                Command::none()
            }
            Message::Setup(hwnd) => {
                state.our_hwnd = Some(hwnd);
                if hwnd != 0 {
                    unsafe { crate::win32::set_window_style(hwnd); }
                }

                crate::win32::init_keyboard_hook();

                let manager = GlobalHotKeyManager::new();
                if let Ok(manager) = manager {
                    let hotkey = HotKey::new(Some(Modifiers::CONTROL | Modifiers::ALT), Code::Period);
                    let _ = manager.register(hotkey);
                    std::mem::forget(manager);
                }

                let icon = {
                    let img = image::load_from_memory(LOGO_BYTES).expect("Failed to load logo");
                    let rgba = img.to_rgba8();
                    tray_icon::Icon::from_rgba(rgba.into_raw(), img.width(), img.height())
                        .expect("Failed to create tray icon")
                };

                let show = MenuItem::with_id(MenuId::new("show-window"), "Show Window", true, None);
                let exit = MenuItem::with_id(MenuId::new("exit"), "Exit", true, None);
                if let Ok(menu) = Menu::with_items(&[&show, &PredefinedMenuItem::separator(), &exit]) {
                    if let Ok(tray) = TrayIconBuilder::new()
                        .with_icon(icon)
                        .with_tooltip("Flemozi")
                        .with_menu(Box::new(menu))
                        .build()
                    {
                        std::mem::forget(tray);
                    }
                }

                Command::none()
            }
            Message::TabSelected(tab) => {
                state.tab = tab;
                Command::none()
            }
            Message::TitleBarDrag => {
                if let Some(id) = state.window_id {
                    window::drag::<Message>(id)
                } else {
                    Command::none()
                }
            }
            Message::TitleBarClose => {
                crate::win32::set_hook_active(false);
                let hwnd = state.our_hwnd.unwrap_or(0);
                if hwnd != 0 {
                    unsafe { crate::win32::hide_window(hwnd); }
                }
                Command::none()
            }
            Message::HotkeyPressed(_event) => {
                state.last_foreground = Some(crate::win32::foreground_window());
                crate::win32::set_hook_active(true);
                let hwnd = state.our_hwnd.unwrap_or(0);
                if hwnd != 0 {
                    let (cx, cy) = crate::win32::get_cursor_pos();
                    let (wx, wy) = crate::win32::clamp_window_position(cx, cy, 500, 500);
                    unsafe { crate::win32::show_no_activate(hwnd, wx, wy); }
                }
                Command::none()
            }
            Message::MenuActivated(event) => {
                if event.id().0 == "exit" {
                    if let Some(id) = state.window_id {
                        window::close::<Message>(id)
                    } else {
                        Command::none()
                    }
                } else if event.id().0 == "show-window" {
                    state.last_foreground = Some(crate::win32::foreground_window());
                    crate::win32::set_hook_active(true);
                    let hwnd = state.our_hwnd.unwrap_or(0);
                    if hwnd != 0 {
                        let (cx, cy) = crate::win32::get_cursor_pos();
                        let (wx, wy) = crate::win32::clamp_window_position(cx, cy, 500, 500);
                        unsafe { crate::win32::show_no_activate(hwnd, wx, wy); }
                    }
                    Command::none()
                } else {
                    Command::none()
                }
            }
            Message::DoType(emoji) => {
                unsafe { crate::win32::paste_emoji(&emoji); }
                Command::none()
            }
            Message::Selected(i) => {
                if state.filtered.contains(&i) {
                    state.selected = i;
                    crate::win32::set_hook_active(false);
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
            Message::CopySelected => {
                crate::win32::set_hook_active(false);
                state.copy()
            }
            Message::ClearSearch => {
                state.query.clear();
                state.cursor = 0;
                state.selection = None;
                state.filtered = (0..state.entries.len()).collect();
                state.selected = state.filtered.first().copied().unwrap_or(0);
                operation::scroll_to(
                    state.scroll_id.clone(),
                    scrollable::AbsoluteOffset { x: 0.0, y: 0.0 },
                )
            }
            Message::Shown(i) => {
                state.visible.insert(i);
                Command::none()
            }
            Message::HookKeyEvent(ev) => {
                let HookKeyEvent { key, ctrl, shift } = ev;
                let mut re_filter = true;
                match key {
                    crate::win32::HookKey::Char(ch) if ctrl && ch == 'a' => {
                        state.cursor = state.query.len();
                        state.selection = Some((0, state.query.len()));
                        re_filter = false;
                    }
                    crate::win32::HookKey::Char(ch) if ctrl && ch == 'c' => {}
                    crate::win32::HookKey::Char(ch) => {
                        if let Some((a, b)) = state.selection.take() {
                            let lo = a.min(b);
                            let hi = a.max(b);
                            state.query.replace_range(lo..hi, "");
                            state.cursor = lo;
                        }
                        state.query.insert(state.cursor, ch);
                        state.cursor += 1;
                    }
                    crate::win32::HookKey::Backspace if ctrl => {
                        state.selection = None;
                        let before = &state.query[..state.cursor];
                        let word_start = before
                            .rfind(|c: char| c == ' ')
                            .map(|i| i + 1)
                            .unwrap_or(0);
                        state.query.replace_range(word_start..state.cursor, "");
                        state.cursor = word_start;
                    }
                    crate::win32::HookKey::Backspace => {
                        if let Some((a, b)) = state.selection.take() {
                            let lo = a.min(b);
                            let hi = a.max(b);
                            state.query.replace_range(lo..hi, "");
                            state.cursor = lo;
                        } else if state.cursor > 0 {
                            let lo = state.cursor - 1;
                            state.query.remove(lo);
                            state.cursor = lo;
                        }
                    }
                    crate::win32::HookKey::Delete if ctrl => {
                        state.selection = None;
                        let after = &state.query[state.cursor..];
                        let word_end = after
                            .find(|c: char| c == ' ')
                            .map(|i| state.cursor + i + 1)
                            .unwrap_or(state.query.len());
                        state.query.replace_range(state.cursor..word_end, "");
                    }
                    crate::win32::HookKey::Delete => {
                        if let Some((a, b)) = state.selection.take() {
                            let lo = a.min(b);
                            let hi = a.max(b);
                            state.query.replace_range(lo..hi, "");
                            state.cursor = lo;
                        } else if state.cursor < state.query.len() {
                            state.query.remove(state.cursor);
                        }
                    }
                    crate::win32::HookKey::Left => {
                        if ctrl {
                            let word_start = state
                                .query[..state.cursor]
                                .rfind(|c: char| c == ' ')
                                .map(|i| i + 1)
                                .unwrap_or(0);
                            if shift {
                                let anchor = state.selection.map_or(state.cursor, |(a, _)| a);
                                state.selection = Some((anchor, word_start));
                            } else {
                                state.selection = None;
                            }
                            state.cursor = word_start;
                        } else if shift {
                            let anchor = state.selection.map_or(state.cursor, |(a, _)| a);
                            if state.cursor > 0 {
                                state.cursor -= 1;
                            }
                            state.selection = Some((anchor, state.cursor));
                        } else {
                            state.selection = None;
                            if state.cursor > 0 {
                                state.cursor -= 1;
                            }
                        }
                    }
                    crate::win32::HookKey::Right => {
                        if ctrl {
                            let after = &state.query[state.cursor..];
                            let word_end = after
                                .find(|c: char| c == ' ')
                                .map(|i| state.cursor + i + 1)
                                .unwrap_or(state.query.len());
                            if shift {
                                let anchor = state.selection.map_or(state.cursor, |(_, b)| b);
                                state.selection = Some((anchor, word_end));
                            } else {
                                state.selection = None;
                            }
                            state.cursor = word_end;
                        } else if shift {
                            let anchor = state.selection.map_or(state.cursor, |(_, b)| b);
                            if state.cursor < state.query.len() {
                                state.cursor += 1;
                            }
                            state.selection = Some((anchor, state.cursor));
                        } else {
                            state.selection = None;
                            if state.cursor < state.query.len() {
                                state.cursor += 1;
                            }
                        }
                    }
                    crate::win32::HookKey::Home => {
                        if shift {
                            let anchor = state.selection.map_or(state.cursor, |(a, _)| a);
                            state.selection = Some((anchor, 0));
                        } else {
                            state.selection = None;
                        }
                        state.cursor = 0;
                    }
                    crate::win32::HookKey::End => {
                        let len = state.query.len();
                        if shift {
                            let anchor = state.selection.map_or(state.cursor, |(_, b)| b);
                            state.selection = Some((anchor, len));
                        } else {
                            state.selection = None;
                        }
                        state.cursor = len;
                    }
                    crate::win32::HookKey::Up => {
                        if state.move_selection(Move::Up) {
                            return state.scroll_to_selected();
                        }
                    }
                    crate::win32::HookKey::Down => {
                        if state.move_selection(Move::Down) {
                            return state.scroll_to_selected();
                        }
                    }
                    crate::win32::HookKey::Enter => {
                        crate::win32::set_hook_active(false);
                        return state.copy();
                    }
                    crate::win32::HookKey::Escape => {
                        if state.query.is_empty() {
                            crate::win32::set_hook_active(false);
                            let hwnd = state.our_hwnd.unwrap_or(0);
                            if hwnd != 0 {
                                unsafe { crate::win32::hide_window(hwnd); }
                            }
                            return Command::none();
                        } else {
                            state.query.clear();
                            state.cursor = 0;
                            state.selection = None;
                        }
                    }
                }
                if re_filter {
                    state.filtered = filter(&state.entries, &state.query);
                    state.selected = state.filtered.first().copied().unwrap_or(0);
                }
                operation::scroll_to(
                    state.scroll_id.clone(),
                    scrollable::AbsoluteOffset { x: 0.0, y: 0.0 },
                )
            }
        }
    }

    pub fn view(&self) -> Element<'_, Message> {
        let Flemozi::Loaded(state) = self;
        main_view(state)
    }

    pub fn subscription(&self) -> Subscription<Message> {
        use keyboard::key;

        let keyboard = event::listen_raw(|event, _status, _window| {
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
        });

        Subscription::batch([
            keyboard,
            window::close_requests().map(|_id| Message::TitleBarClose),
            titlebar_drag_subscription(),
            Subscription::run(external_events),
        ])
    }
}

fn cursor_pos() -> Option<Point> {
    LAST_CURSOR.lock().ok().and_then(|guard| *guard)
}

fn titlebar_drag_subscription() -> Subscription<Message> {
    event::listen_raw(|event, _status, _window| match event {
        iced::Event::Mouse(mouse::Event::CursorMoved { position }) => {
            if let Ok(mut pos) = LAST_CURSOR.lock() {
                *pos = Some(position);
            }
            None
        }
        iced::Event::Mouse(mouse::Event::ButtonPressed(mouse::Button::Left)) => {
            if let Some(pos) = cursor_pos() {
                if pos.y > 0.0 && pos.y < 22.0 && pos.x < 460.0 {
                    return Some(Message::TitleBarDrag);
                }
            }
            None
        }
        _ => None,
    })
}

fn external_events() -> impl iced::futures::Stream<Item = Message> {
    stream::channel(64, async move |mut output| {
        let hotkey_rx = GlobalHotKeyEvent::receiver();
        let menu_rx = MenuEvent::receiver();

        loop {
            while let Ok(event) = hotkey_rx.try_recv() {
                let _ = output.try_send(Message::HotkeyPressed(event));
            }
            while let Ok(event) = menu_rx.try_recv() {
                let _ = output.try_send(Message::MenuActivated(event));
            }
            while let Some(key) = crate::win32::try_recv_hook_key() {
                let _ = output.try_send(Message::HookKeyEvent(key));
            }
            tokio::time::sleep(std::time::Duration::from_millis(4)).await;
        }
    })
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
        let content_width = 500.0 - 42.0 - 24.0;
        let gaps = (COLUMNS - 1) as f32 * SPACING;
        let cell_width = (content_width - gaps) / COLUMNS as f32;
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

        if let Some(_id) = self.window_id {
            let hwnd = self.our_hwnd.unwrap_or(0);
            if hwnd != 0 {
                unsafe { crate::win32::hide_window(hwnd); }
            }
            Command::future(async move {
                Message::DoType(emoji)
            })
        } else {
            clipboard::write::<Message>(emoji)
        }
    }
}
