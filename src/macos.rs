use std::sync::atomic::{AtomicBool, Ordering};
use std::sync::mpsc::{Receiver, Sender, channel};
use std::sync::{Mutex, OnceLock};

use core_foundation::runloop::CFRunLoop;
use core_graphics::event::{
    CallbackResult, CGEventFlags, CGEventTap, CGEventTapLocation, CGEventTapOptions,
    CGEventTapPlacement, CGEventType, EventField, KeyCode,
};
use tracing::{error, info, warn};

use objc2::msg_send;
use objc2::runtime::{AnyClass, AnyObject, Bool};
use objc2_foundation::{NSPoint, NSRect};

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum HookKey {
    Char(char),
    Backspace,
    Delete,
    Home,
    End,
    Up,
    Down,
    Left,
    Right,
    Enter,
    Escape,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct HookKeyEvent {
    pub key: HookKey,
    pub ctrl: bool,
    pub shift: bool,
    pub alt: bool,
}

static HOOK_ACTIVE: AtomicBool = AtomicBool::new(false);

pub fn set_hook_active(active: bool) {
    HOOK_ACTIVE.store(active, Ordering::SeqCst);
}

#[allow(dead_code)]
pub fn is_hook_active() -> bool {
    HOOK_ACTIVE.load(Ordering::SeqCst)
}

static HOOK_CHANNEL: OnceLock<(Mutex<Sender<HookKeyEvent>>, Mutex<Receiver<HookKeyEvent>>)> =
    OnceLock::new();

pub fn try_recv_hook_key() -> Option<HookKeyEvent> {
    let ev = HOOK_CHANNEL
        .get()
        .and_then(|(_, rx)| {
            rx.lock()
                .inspect_err(|e| warn!("try_recv_hook_key: mutex poisoned: {e}"))
                .ok()
        })
        .and_then(|rx| rx.try_recv().ok());
    if ev.is_some() {
        info!("try_recv_hook_key: received {ev:?}");
    }
    ev
}

pub fn init_keyboard_hook() {
    info!("init_keyboard_hook: called");
    if HOOK_CHANNEL.get().is_some() {
        info!("init_keyboard_hook: already initialised");
        return;
    }

    let (tx, rx) = channel::<HookKeyEvent>();
    if let Err(e) = HOOK_CHANNEL.set((Mutex::new(tx.clone()), Mutex::new(rx))) {
        error!("init_keyboard_hook: failed to set channel: {e:?}");
        return;
    }
    info!("init_keyboard_hook: channel created, spawning listener thread");

    std::thread::spawn(move || {
        info!("init_keyboard_hook: listener thread started, creating CGEventTap");
        let result = CGEventTap::with_enabled(
            CGEventTapLocation::HID,
            CGEventTapPlacement::HeadInsertEventTap,
            CGEventTapOptions::ListenOnly,
            vec![
                CGEventType::KeyDown,
                CGEventType::KeyUp,
                CGEventType::FlagsChanged,
            ],
            move |_proxy, event_type, event| {
                let active = HOOK_ACTIVE.load(Ordering::SeqCst);
                info!("cgevent tap: active={active}, event_type={event_type:?}");

                match event_type {
                    CGEventType::KeyDown | CGEventType::KeyUp => {
                        let code = event.get_integer_value_field(EventField::KEYBOARD_EVENT_KEYCODE) as u16;
                        let flags = event.get_flags();
                        let ctrl = flags.contains(CGEventFlags::CGEventFlagControl);
                        let shift = flags.contains(CGEventFlags::CGEventFlagShift);
                        let alt = flags.contains(CGEventFlags::CGEventFlagAlternate);

                        info!("cgevent tap: key code={code} ctrl={ctrl} shift={shift} alt={alt}");

                        if !active {
                            return CallbackResult::Keep;
                        }

                        if matches!(event_type, CGEventType::KeyDown) {
                            if let Some(ev) = keycode_to_hook_event(code, shift, ctrl, alt) {
                                info!("cgevent tap: sending {ev:?}");
                                if let Err(e) = tx.send(ev) {
                                    warn!("cgevent tap: send failed: {e}");
                                }
                            }
                        }
                    }
                    CGEventType::FlagsChanged => {
                        // Modifier-only event; we read flags from regular key events.
                    }
                    CGEventType::TapDisabledByTimeout => {
                        warn!("cgevent tap: disabled by timeout");
                    }
                    CGEventType::TapDisabledByUserInput => {
                        warn!("cgevent tap: disabled by user input");
                    }
                    _ => {}
                }

                CallbackResult::Keep
            },
            || {
                info!("cgevent tap: entering CFRunLoop");
                CFRunLoop::run_current();
                info!("cgevent tap: CFRunLoop exited");
            },
        );

        if let Err(()) = result {
            error!("cgevent tap: failed to create event tap. Grant Accessibility permission in System Settings → Privacy & Security → Accessibility.");
        }
    });
}

fn keycode_to_hook_event(code: u16, shift: bool, ctrl: bool, alt: bool) -> Option<HookKeyEvent> {
    let key = match code {
        KeyCode::DELETE => HookKey::Backspace,
        KeyCode::FORWARD_DELETE => HookKey::Delete,
        KeyCode::HOME => HookKey::Home,
        KeyCode::END => HookKey::End,
        KeyCode::UP_ARROW => HookKey::Up,
        KeyCode::DOWN_ARROW => HookKey::Down,
        KeyCode::LEFT_ARROW => HookKey::Left,
        KeyCode::RIGHT_ARROW => HookKey::Right,
        KeyCode::RETURN => HookKey::Enter,
        KeyCode::ESCAPE => HookKey::Escape,
        _ => {
            if let Some(ch) = keycode_to_char(code, shift) {
                HookKey::Char(ch)
            } else {
                return None;
            }
        }
    };

    Some(HookKeyEvent {
        key,
        ctrl,
        shift,
        alt,
    })
}

fn keycode_to_char(code: u16, shift: bool) -> Option<char> {
    // US QWERTY layout mapping. Layout-dependent, matching rdev's behaviour.
    let (normal, shifted) = match code {
        KeyCode::ANSI_A => ('a', 'A'),
        KeyCode::ANSI_B => ('b', 'B'),
        KeyCode::ANSI_C => ('c', 'C'),
        KeyCode::ANSI_D => ('d', 'D'),
        KeyCode::ANSI_E => ('e', 'E'),
        KeyCode::ANSI_F => ('f', 'F'),
        KeyCode::ANSI_G => ('g', 'G'),
        KeyCode::ANSI_H => ('h', 'H'),
        KeyCode::ANSI_I => ('i', 'I'),
        KeyCode::ANSI_J => ('j', 'J'),
        KeyCode::ANSI_K => ('k', 'K'),
        KeyCode::ANSI_L => ('l', 'L'),
        KeyCode::ANSI_M => ('m', 'M'),
        KeyCode::ANSI_N => ('n', 'N'),
        KeyCode::ANSI_O => ('o', 'O'),
        KeyCode::ANSI_P => ('p', 'P'),
        KeyCode::ANSI_Q => ('q', 'Q'),
        KeyCode::ANSI_R => ('r', 'R'),
        KeyCode::ANSI_S => ('s', 'S'),
        KeyCode::ANSI_T => ('t', 'T'),
        KeyCode::ANSI_U => ('u', 'U'),
        KeyCode::ANSI_V => ('v', 'V'),
        KeyCode::ANSI_W => ('w', 'W'),
        KeyCode::ANSI_X => ('x', 'X'),
        KeyCode::ANSI_Y => ('y', 'Y'),
        KeyCode::ANSI_Z => ('z', 'Z'),
        KeyCode::ANSI_1 => ('1', '!'),
        KeyCode::ANSI_2 => ('2', '@'),
        KeyCode::ANSI_3 => ('3', '#'),
        KeyCode::ANSI_4 => ('4', '$'),
        KeyCode::ANSI_5 => ('5', '%'),
        KeyCode::ANSI_6 => ('6', '^'),
        KeyCode::ANSI_7 => ('7', '&'),
        KeyCode::ANSI_8 => ('8', '*'),
        KeyCode::ANSI_9 => ('9', '('),
        KeyCode::ANSI_0 => ('0', ')'),
        KeyCode::ANSI_MINUS => ('-', '_'),
        KeyCode::ANSI_EQUAL => ('=', '+'),
        KeyCode::ANSI_LEFT_BRACKET => ('[', '{'),
        KeyCode::ANSI_RIGHT_BRACKET => (']', '}'),
        KeyCode::ANSI_BACKSLASH => ('\\', '|'),
        KeyCode::ANSI_SEMICOLON => (';', ':'),
        KeyCode::ANSI_QUOTE => ('\'', '"'),
        KeyCode::ANSI_COMMA => (',', '<'),
        KeyCode::ANSI_PERIOD => ('.', '>'),
        KeyCode::ANSI_SLASH => ('/', '?'),
        KeyCode::ANSI_GRAVE => ('`', '~'),
        KeyCode::SPACE => (' ', ' '),
        KeyCode::TAB => ('\t', '\t'),
        _ => return None,
    };
    Some(if shift { shifted } else { normal })
}

fn ns_view_to_window(ns_view: isize) -> *const AnyObject {
    if ns_view == 0 {
        return std::ptr::null();
    }
    let view: &AnyObject = unsafe { &*(ns_view as *const AnyObject) };
    unsafe { msg_send![view, window] }
}

fn as_ref<'a>(ptr: *const AnyObject) -> Option<&'a AnyObject> {
    if ptr.is_null() {
        None
    } else {
        unsafe { Some(&*ptr) }
    }
}

pub fn foreground_window() -> isize {
    info!("foreground_window: called");
    unsafe {
        let workspace: *const AnyObject =
            msg_send![AnyClass::get(c"NSWorkspace").unwrap(), sharedWorkspace];
        let Some(workspace) = as_ref(workspace) else {
            warn!("foreground_window: sharedWorkspace returned nil");
            return 0;
        };
        let app: *const AnyObject = msg_send![workspace, frontmostApplication];
        let Some(app) = as_ref(app) else {
            warn!("foreground_window: frontmostApplication returned nil");
            return 0;
        };
        let pid: i32 = msg_send![app, processIdentifier];
        info!("foreground_window: pid={pid}");
        pid as isize
    }
}

pub fn get_cursor_pos() -> (i32, i32) {
    unsafe {
        let pt: NSPoint = msg_send![AnyClass::get(c"NSEvent").unwrap(), mouseLocation];
        info!("get_cursor_pos: ({}, {})", pt.x as i32, pt.y as i32);
        (pt.x as i32, pt.y as i32)
    }
}

pub fn get_screen_size() -> (i32, i32) {
    unsafe {
        let screen: *const AnyObject =
            msg_send![AnyClass::get(c"NSScreen").unwrap(), mainScreen];
        let Some(screen) = as_ref(screen) else {
            warn!("get_screen_size: mainScreen returned nil, returning fallback");
            return (1920, 1080);
        };
        let frame: NSRect = msg_send![screen, frame];
        info!("get_screen_size: {}x{}", frame.size.width as i32, frame.size.height as i32);
        (frame.size.width as i32, frame.size.height as i32)
    }
}

pub fn clamp_window_position(mut cx: i32, mut cy: i32, win_w: i32, win_h: i32) -> (i32, i32) {
    let (sw, sh) = get_screen_size();
    info!("clamp_window_position: input=({cx},{cy}) win={win_w}x{win_h} screen={sw}x{sh}");
    cx -= win_w / 2;

    if cy + 24 + win_h <= sh {
        cy += 24;
    } else {
        cy = (cy - win_h - 24).max(0);
    }

    cx = cx.clamp(0, (sw - win_w).max(0));
    cy = cy.clamp(0, (sh - win_h).max(0));
    info!("clamp_window_position: output=({cx},{cy})");
    (cx, cy)
}

pub unsafe fn set_window_style(ns_view: isize) {
    info!("set_window_style: ns_view={ns_view}");
    let window = ns_view_to_window(ns_view);
    let Some(window) = as_ref(window) else {
        warn!("set_window_style: could not get NSWindow from NSView");
        return;
    };

    info!("set_window_style: setting level");
    let _: () = msg_send![window, setLevel: 3isize];
    info!("set_window_style: setting collection behavior");
    let _: () = msg_send![window, setCollectionBehavior: (1u64 << 0) | (1u64 << 3)];
    info!("set_window_style: setting hasShadow");
    let _: () = msg_send![window, setHasShadow: Bool::YES];
    info!("set_window_style: setting opaque");
    let _: () = msg_send![window, setOpaque: Bool::NO];
    info!("set_window_style: done");
}

pub unsafe fn show_no_activate(ns_view: isize, x: i32, y: i32) {
    info!("show_no_activate: ns_view={ns_view} pos=({x},{y})");
    let window = ns_view_to_window(ns_view);
    let Some(window) = as_ref(window) else {
        warn!("show_no_activate: could not get NSWindow from NSView");
        return;
    };
    info!("show_no_activate: calling setFrameTopLeftPoint");
    let _: () =
        msg_send![window, setFrameTopLeftPoint: NSPoint::new(x as f64, y as f64)];
    info!("show_no_activate: calling orderFrontRegardless");
    let _: () = msg_send![window, orderFrontRegardless];
    info!("show_no_activate: done");
}

pub unsafe fn hide_window(ns_view: isize) {
    info!("hide_window: ns_view={ns_view}");
    let window = ns_view_to_window(ns_view);
    let Some(window) = as_ref(window) else {
        warn!("hide_window: could not get NSWindow from NSView");
        return;
    };
    info!("hide_window: calling orderOut");
    let _: () = msg_send![window, orderOut: std::ptr::null::<AnyObject>()];
    info!("hide_window: done");
}

pub unsafe fn paste_emoji(text: &str) {
    info!("paste_emoji: text_len={}", text.len());
    let saved = match arboard::Clipboard::new() {
        Ok(mut c) => match c.get_text() {
            Ok(t) => {
                info!("paste_emoji: saved previous clipboard text");
                Some(t)
            }
            Err(e) => {
                warn!("paste_emoji: failed to read clipboard for save: {e}");
                None
            }
        },
        Err(e) => {
            warn!("paste_emoji: failed to open clipboard for save: {e}");
            None
        }
    };

    match arboard::Clipboard::new() {
        Ok(mut c) => {
            if let Err(e) = c.set_text(text) {
                error!("paste_emoji: failed to set clipboard text: {e}");
                return;
            }
            info!("paste_emoji: clipboard text set");
        }
        Err(e) => {
            error!("paste_emoji: failed to open clipboard for writing: {e}");
            return;
        }
    }

    std::thread::sleep(std::time::Duration::from_millis(10));

    info!("paste_emoji: simulating Cmd+V");
    simulate_cmd_v();

    std::thread::sleep(std::time::Duration::from_millis(50));

    match saved {
        Some(prev) => match arboard::Clipboard::new() {
            Ok(mut c) => {
                if let Err(e) = c.set_text(prev) {
                    error!("paste_emoji: failed to restore clipboard text: {e}");
                } else {
                    info!("paste_emoji: clipboard restored");
                }
            }
            Err(e) => error!("paste_emoji: failed to open clipboard for restore: {e}"),
        },
        None => match arboard::Clipboard::new() {
            Ok(mut c) => {
                if let Err(e) = c.clear() {
                    warn!("paste_emoji: failed to clear clipboard: {e}");
                } else {
                    info!("paste_emoji: clipboard cleared");
                }
            }
            Err(e) => warn!("paste_emoji: failed to open clipboard for clearing: {e}"),
        },
    }
    info!("paste_emoji: finished");
}

pub unsafe fn paste_gif_file(bytes: &[u8]) {
    info!("paste_gif_file: bytes={}", bytes.len());
    let pb: *const AnyObject =
        msg_send![AnyClass::get(c"NSPasteboard").unwrap(), generalPasteboard];
    let Some(pb) = as_ref(pb) else {
        error!("paste_gif_file: generalPasteboard returned nil");
        return;
    };

    info!("paste_gif_file: clearing pasteboard");
    let _: isize = msg_send![pb, clearContents];

    info!("paste_gif_file: creating NSData");
    let ns_data: *const AnyObject = msg_send![
        AnyClass::get(c"NSData").unwrap(),
        dataWithBytes: bytes.as_ptr(),
        length: bytes.len()
    ];
    let Some(ns_data) = as_ref(ns_data) else {
        error!("paste_gif_file: NSData allocation failed");
        return;
    };

    info!("paste_gif_file: creating type string");
    let type_str: *const AnyObject = msg_send![
        AnyClass::get(c"NSString").unwrap(),
        stringWithUTF8String: c"com.compuserve.gif".as_ptr()
    ];
    let Some(type_str) = as_ref(type_str) else {
        error!("paste_gif_file: type string allocation failed");
        return;
    };

    info!("paste_gif_file: writing GIF data");
    let success: bool = msg_send![pb, setData: ns_data, forType: type_str];
    if !success {
        error!("paste_gif_file: NSPasteboard rejected GIF data");
        return;
    }
    info!("paste_gif_file: GIF written to pasteboard");

    std::thread::sleep(std::time::Duration::from_millis(15));

    info!("paste_gif_file: simulating Cmd+V");
    simulate_cmd_v();
    info!("paste_gif_file: finished");
}

fn simulate_cmd_v() {
    info!("simulate_cmd_v: start");
    let cmd = 0x37u16;
    let v = 0x09u16;
    let cmd_flag: u64 = 0x0010_0000;

    unsafe {
        let cmd_down = CGEventCreateKeyboardEvent(std::ptr::null(), cmd, true);
        let v_down = CGEventCreateKeyboardEvent(std::ptr::null(), v, true);
        let v_up = CGEventCreateKeyboardEvent(std::ptr::null(), v, false);
        let cmd_up = CGEventCreateKeyboardEvent(std::ptr::null(), cmd, false);
        info!("simulate_cmd_v: events created cmd_down={cmd_down:?} v_down={v_down:?}");

        if !v_down.is_null() {
            CGEventSetFlags(v_down, CGEventGetFlags(v_down) | cmd_flag);
        }

        let tap = CG_SESSION_EVENT_TAP;

        if !cmd_down.is_null() {
            CGEventPost(tap, cmd_down);
            CFRelease(cmd_down);
        }
        std::thread::sleep(std::time::Duration::from_millis(8));

        if !v_down.is_null() {
            CGEventPost(tap, v_down);
            CFRelease(v_down);
        }
        std::thread::sleep(std::time::Duration::from_millis(8));

        if !v_up.is_null() {
            CGEventPost(tap, v_up);
            CFRelease(v_up);
        }
        std::thread::sleep(std::time::Duration::from_millis(8));

        if !cmd_up.is_null() {
            CGEventPost(tap, cmd_up);
            CFRelease(cmd_up);
        }
    }
    info!("simulate_cmd_v: end");
}

const CG_SESSION_EVENT_TAP: u32 = 1;

unsafe extern "C" {
    fn CGEventCreateKeyboardEvent(
        source: *const std::ffi::c_void,
        virtualKey: u16,
        keyDown: bool,
    ) -> *mut std::ffi::c_void;

    fn CGEventPost(tap: u32, event: *mut std::ffi::c_void);

    fn CGEventSetFlags(event: *mut std::ffi::c_void, flags: u64);

    fn CGEventGetFlags(event: *mut std::ffi::c_void) -> u64;

    fn CFRelease(cf: *mut std::ffi::c_void);
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn keycode_mapping() {
        assert_eq!(
            keycode_to_hook_event(KeyCode::DELETE, false, false, false),
            Some(HookKeyEvent { key: HookKey::Backspace, ctrl: false, shift: false, alt: false })
        );
        assert_eq!(
            keycode_to_hook_event(KeyCode::FORWARD_DELETE, false, false, false),
            Some(HookKeyEvent { key: HookKey::Delete, ctrl: false, shift: false, alt: false })
        );
        assert_eq!(
            keycode_to_hook_event(KeyCode::HOME, false, false, false),
            Some(HookKeyEvent { key: HookKey::Home, ctrl: false, shift: false, alt: false })
        );
        assert_eq!(
            keycode_to_hook_event(KeyCode::END, false, false, false),
            Some(HookKeyEvent { key: HookKey::End, ctrl: false, shift: false, alt: false })
        );
        assert_eq!(
            keycode_to_hook_event(KeyCode::UP_ARROW, false, false, false),
            Some(HookKeyEvent { key: HookKey::Up, ctrl: false, shift: false, alt: false })
        );
        assert_eq!(
            keycode_to_hook_event(KeyCode::DOWN_ARROW, false, false, false),
            Some(HookKeyEvent { key: HookKey::Down, ctrl: false, shift: false, alt: false })
        );
        assert_eq!(
            keycode_to_hook_event(KeyCode::LEFT_ARROW, false, false, false),
            Some(HookKeyEvent { key: HookKey::Left, ctrl: false, shift: false, alt: false })
        );
        assert_eq!(
            keycode_to_hook_event(KeyCode::RIGHT_ARROW, false, false, false),
            Some(HookKeyEvent { key: HookKey::Right, ctrl: false, shift: false, alt: false })
        );
        assert_eq!(
            keycode_to_hook_event(KeyCode::RETURN, false, false, false),
            Some(HookKeyEvent { key: HookKey::Enter, ctrl: false, shift: false, alt: false })
        );
        assert_eq!(
            keycode_to_hook_event(KeyCode::ESCAPE, false, false, false),
            Some(HookKeyEvent { key: HookKey::Escape, ctrl: false, shift: false, alt: false })
        );
        assert!(keycode_to_hook_event(KeyCode::CONTROL, false, false, false).is_none());
    }

    #[test]
    fn char_mapping() {
        assert_eq!(keycode_to_char(KeyCode::ANSI_A, false), Some('a'));
        assert_eq!(keycode_to_char(KeyCode::ANSI_A, true), Some('A'));
        assert_eq!(keycode_to_char(KeyCode::ANSI_1, false), Some('1'));
        assert_eq!(keycode_to_char(KeyCode::ANSI_1, true), Some('!'));
        assert_eq!(keycode_to_char(KeyCode::SPACE, false), Some(' '));
        assert_eq!(keycode_to_char(KeyCode::CONTROL, false), None);
    }

    #[test]
    fn hook_active_flag() {
        set_hook_active(false);
        assert!(!is_hook_active());
        set_hook_active(true);
        assert!(is_hook_active());
        set_hook_active(false);
        assert!(!is_hook_active());
    }

    #[test]
    fn as_ref_null() {
        assert!(as_ref(std::ptr::null()).is_none());
    }
}
