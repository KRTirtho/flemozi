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
    pub entries: Vec<EmojiEntry>,
    pub filtered: Vec<usize>,
    pub selected: usize,
    pub copied: Option<String>,
    pub visible: HashSet<usize>,
    pub search_id: widget::Id,
    pub scroll_id: widget::Id,
    pub tab: Tab,
    pub window_id: Option<window::Id>,
    pub our_hwnd: Option<isize>,
    pub last_foreground: Option<isize>,
}

#[derive(Debug, Clone)]
pub enum Message {
    SearchChanged(String),
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
    DoType(isize, String),
    Noop,
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
            tab: Tab::Emojis,
            window_id: None,
            our_hwnd: None,
            last_foreground: None,
        };

        let cmd = Command::batch([
            operation::focus("search"),
            window::latest().map(Message::Init),
        ]);

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
                if let Some(id) = state.window_id {
                    window::set_mode::<Message>(id, window::Mode::Hidden)
                } else {
                    Command::none()
                }
            }
            Message::HotkeyPressed(_event) => {
                state.last_foreground = Some(crate::win32::foreground_window());
                if let Some(hwnd) = state.our_hwnd.filter(|&h| h != 0) {
                    return Command::future(async move {
                        tokio::time::sleep(std::time::Duration::from_millis(20)).await;
                        unsafe { crate::win32::show_no_activate(hwnd); }
                    })
                    .map(|_| Message::Noop);
                }
                if let Some(id) = state.window_id {
                    Command::batch([
                        window::set_mode::<Message>(id, window::Mode::Windowed),
                        window::gain_focus::<Message>(id),
                    ])
                } else {
                    Command::none()
                }
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
                    if let Some(hwnd) = state.our_hwnd.filter(|&h| h != 0) {
                        return Command::future(async move {
                            tokio::time::sleep(std::time::Duration::from_millis(20)).await;
                            unsafe { crate::win32::show_no_activate(hwnd); }
                        })
                        .map(|_| Message::Noop);
                    }
                    if let Some(id) = state.window_id {
                        Command::batch([
                            window::set_mode::<Message>(id, window::Mode::Windowed),
                            window::gain_focus::<Message>(id),
                        ])
                    } else {
                        Command::none()
                    }
                } else {
                    Command::none()
                }
            }
            Message::DoType(hwnd, emoji) => {
                if hwnd != 0 {
                    unsafe { crate::win32::paste_emoji(hwnd, &emoji); }
                } else {
                    return clipboard::write::<Message>(emoji);
                }
                Command::none()
            }
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
            Message::Noop => Command::none(),
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
            tokio::time::sleep(std::time::Duration::from_millis(200)).await;
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

        let hwnd = self.last_foreground.unwrap_or(0);

        if let Some(id) = self.window_id {
            Command::batch([
                window::set_mode::<Message>(id, window::Mode::Hidden),
                Command::future(async move {
                    tokio::time::sleep(std::time::Duration::from_millis(100)).await;
                    Message::DoType(hwnd, emoji)
                }),
            ])
        } else {
            clipboard::write::<Message>(emoji)
        }
    }
}
