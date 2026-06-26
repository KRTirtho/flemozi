#[cfg(target_os = "windows")]
use std::sync::atomic::{AtomicBool, Ordering};
#[cfg(target_os = "windows")]
use std::sync::mpsc::{Receiver, Sender, channel};
#[cfg(target_os = "windows")]
use std::sync::{Mutex, OnceLock};
#[cfg(target_os = "windows")]
use std::os::windows::ffi::OsStrExt;

#[cfg(target_os = "windows")]
use windows::Win32::Foundation::{HWND, LPARAM, LRESULT, POINT, WPARAM};
#[cfg(target_os = "windows")]
use windows::Win32::UI::Input::KeyboardAndMouse::{
    GetKeyState, INPUT, INPUT_0, INPUT_KEYBOARD, KEYBD_EVENT_FLAGS, KEYBDINPUT, KEYEVENTF_KEYUP,
    SendInput, VIRTUAL_KEY, VK_BACK, VK_CAPITAL, VK_CONTROL, VK_DELETE, VK_DOWN, VK_END,
    VK_ESCAPE, VK_HOME, VK_LEFT, VK_MENU, VK_RETURN, VK_RIGHT, VK_SHIFT, VK_SPACE, VK_UP,
};
#[cfg(target_os = "windows")]
use windows::Win32::UI::WindowsAndMessaging::{
    CallNextHookEx, DispatchMessageW, GWL_EXSTYLE, GetCursorPos, GetForegroundWindow, GetMessageW,
    GetSystemMetrics, GetWindowLongW, HWND_TOPMOST, MSG, SM_CXSCREEN, SM_CYSCREEN, SW_HIDE,
    SW_SHOWNOACTIVATE, SWP_NOACTIVATE, SWP_NOSIZE, SWP_SHOWWINDOW, SetWindowLongW, SetWindowPos,
    SetWindowsHookExW, ShowWindow, TranslateMessage, UnhookWindowsHookEx, WH_KEYBOARD_LL,
    WM_KEYDOWN, WM_SYSKEYDOWN, WS_EX_NOACTIVATE, WS_EX_TOOLWINDOW, WS_EX_TOPMOST,
};
#[cfg(target_os = "windows")]
use windows::Win32::System::DataExchange::{CloseClipboard, EmptyClipboard, OpenClipboard, SetClipboardData};
#[cfg(target_os = "windows")]
use windows::Win32::System::Memory::{GlobalAlloc, GlobalLock, GlobalUnlock, GHND};
#[cfg(target_os = "windows")]
use windows::Win32::Foundation::HANDLE;

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

#[cfg(target_os = "windows")]
static HOOK_ACTIVE: AtomicBool = AtomicBool::new(false);

pub fn set_hook_active(active: bool) {
    #[cfg(target_os = "windows")]
    HOOK_ACTIVE.store(active, Ordering::SeqCst);
    #[cfg(not(target_os = "windows"))]
    let _ = active;
}

#[allow(dead_code)]
pub fn is_hook_active() -> bool {
    #[cfg(target_os = "windows")]
    {
        HOOK_ACTIVE.load(Ordering::SeqCst)
    }
    #[cfg(not(target_os = "windows"))]
    false
}

#[cfg(target_os = "windows")]
static HOOK_CHANNEL: OnceLock<(Mutex<Sender<HookKeyEvent>>, Mutex<Receiver<HookKeyEvent>>)> =
    OnceLock::new();

pub fn try_recv_hook_key() -> Option<HookKeyEvent> {
    #[cfg(target_os = "windows")]
    {
        HOOK_CHANNEL
            .get()
            .and_then(|(_, rx)| rx.lock().ok())
            .and_then(|rx| rx.try_recv().ok())
    }
    #[cfg(not(target_os = "windows"))]
    None
}

#[cfg(target_os = "windows")]
pub fn init_keyboard_hook() {
    if HOOK_CHANNEL.get().is_some() {
        return;
    }

    let (tx, rx) = channel::<HookKeyEvent>();
    HOOK_CHANNEL.set((Mutex::new(tx), Mutex::new(rx))).ok();

    let _ = HOOK_CHANNEL.get().map(|(tx, _)| {
        let tx = tx.lock().unwrap().clone();
        std::thread::spawn(move || unsafe {
            let hook = SetWindowsHookExW(WH_KEYBOARD_LL, Some(hook_proc), None, 0);
            match hook {
                Ok(h) => {
                    let mut msg = MSG::default();
                    while GetMessageW(&mut msg, None, 0, 0).as_bool() {
                        let _ = TranslateMessage(&msg);
                        DispatchMessageW(&msg);
                    }
                    let _ = UnhookWindowsHookEx(h);
                }
                Err(_) => {}
            }
            drop(tx);
        });
    });
}

#[cfg(target_os = "windows")]
unsafe extern "system" fn hook_proc(code: i32, w_param: WPARAM, l_param: LPARAM) -> LRESULT {
    if code < 0 {
        return unsafe { CallNextHookEx(None, code, w_param, l_param) };
    }

    if !HOOK_ACTIVE.load(Ordering::SeqCst) {
        return unsafe { CallNextHookEx(None, code, w_param, l_param) };
    }

    let msg = w_param.0 as u32;
    if msg != WM_KEYDOWN && msg != WM_SYSKEYDOWN {
        return unsafe { CallNextHookEx(None, code, w_param, l_param) };
    }

    #[repr(C)]
    struct Kbdllhookstruct {
        vk_code: u32,
        scan_code: u32,
        flags: u32,
        time: u32,
        dw_extra_info: usize,
    }

    let kb = unsafe { &*(l_param.0 as *const Kbdllhookstruct) };

    if kb.flags & 0x80 != 0 {
        return unsafe { CallNextHookEx(None, code, w_param, l_param) };
    }

    let shift = (unsafe { GetKeyState(VK_SHIFT.0 as i32) } as u16 & 0x8000) != 0;
    let ctrl = (unsafe { GetKeyState(VK_CONTROL.0 as i32) } as u16 & 0x8000) != 0;
    let alt = (unsafe { GetKeyState(VK_MENU.0 as i32) } as u16 & 0x8000) != 0;

    let key = match kb.vk_code {
        v if v == VK_BACK.0 as u32 => Some(HookKey::Backspace),
        v if v == VK_DELETE.0 as u32 => Some(HookKey::Delete),
        v if v == VK_HOME.0 as u32 => Some(HookKey::Home),
        v if v == VK_END.0 as u32 => Some(HookKey::End),
        v if v == VK_RETURN.0 as u32 => Some(HookKey::Enter),
        v if v == VK_ESCAPE.0 as u32 => Some(HookKey::Escape),
        v if v == VK_LEFT.0 as u32 => Some(HookKey::Left),
        v if v == VK_UP.0 as u32 => Some(HookKey::Up),
        v if v == VK_RIGHT.0 as u32 => Some(HookKey::Right),
        v if v == VK_DOWN.0 as u32 => Some(HookKey::Down),
        _ => {
            let caps = (unsafe { GetKeyState(VK_CAPITAL.0 as i32) } & 1) != 0;
            vk_to_char(kb.vk_code, shift, caps).map(HookKey::Char)
        }
    };

    if let Some(k) = key {
        if let Some((tx, _)) = HOOK_CHANNEL.get() {
            let _ = tx.lock().ok().map(|tx| tx.send(HookKeyEvent { key: k, ctrl, shift, alt }));
        }
        return LRESULT(1);
    }

    unsafe { CallNextHookEx(None, code, w_param, l_param) }
}

#[cfg(target_os = "windows")]
fn vk_to_char(vk: u32, shift: bool, caps: bool) -> Option<char> {
    let uppercase = shift ^ caps;

    match vk {
        0x41..=0x5A => {
            let c = char::from_u32(if uppercase { vk } else { vk + 32 })?;
            Some(c)
        }
        0x30..=0x39 => {
            if shift {
                Some(match vk {
                    0x30 => ')',
                    0x31 => '!',
                    0x32 => '@',
                    0x33 => '#',
                    0x34 => '$',
                    0x35 => '%',
                    0x36 => '^',
                    0x37 => '&',
                    0x38 => '*',
                    0x39 => '(',
                    _ => return None,
                })
            } else {
                char::from_u32(vk)
            }
        }
        v if v == VK_SPACE.0 as u32 => Some(' '),
        0xBD => Some(if shift { '_' } else { '-' }),
        0xBB => Some(if shift { '+' } else { '=' }),
        0xDB => Some(if shift { '{' } else { '[' }),
        0xDD => Some(if shift { '}' } else { ']' }),
        0xDC => Some(if shift { '|' } else { '\\' }),
        0xBA => Some(if shift { ':' } else { ';' }),
        0xDE => Some(if shift { '"' } else { '\'' }),
        0xBC => Some(if shift { '<' } else { ',' }),
        0xBE => Some(if shift { '>' } else { '.' }),
        0xBF => Some(if shift { '?' } else { '/' }),
        0xC0 => Some(if shift { '~' } else { '`' }),
        0x6A => Some('*'),
        0x6B => Some('+'),
        0x6D => Some('-'),
        0x6E => Some('.'),
        0x6F => Some('/'),
        _ => None,
    }
}

#[cfg(target_os = "windows")]
pub fn foreground_window() -> isize {
    unsafe { GetForegroundWindow().0 as isize }
}

#[cfg(target_os = "windows")]
pub fn get_cursor_pos() -> (i32, i32) {
    let mut pt = POINT::default();
    unsafe {
        let _ = GetCursorPos(&mut pt);
    }
    (pt.x, pt.y)
}

#[cfg(target_os = "windows")]
pub fn get_screen_size() -> (i32, i32) {
    unsafe {
        let w = GetSystemMetrics(SM_CXSCREEN);
        let h = GetSystemMetrics(SM_CYSCREEN);
        (w, h)
    }
}

pub fn clamp_window_position(mut cx: i32, mut cy: i32, win_w: i32, win_h: i32) -> (i32, i32) {
    #[cfg(target_os = "windows")]
    {
        let (sw, sh) = get_screen_size();
        cx -= win_w / 2;

        if cy + 24 + win_h <= sh {
            cy += 24;
        } else {
            cy = (cy - win_h - 24).max(0);
        }

        cx = cx.clamp(0, (sw - win_w).max(0));
        cy = cy.clamp(0, (sh - win_h).max(0));
    }
    #[cfg(not(target_os = "windows"))]
    {
        let _ = (win_w, win_h);
    }
    (cx, cy)
}

#[cfg(target_os = "windows")]
pub unsafe fn set_window_style(hwnd: isize) {
    let hwnd = HWND(hwnd as *mut _);
    unsafe {
        let style = GetWindowLongW(hwnd, GWL_EXSTYLE);
        let new_style = style
            | (WS_EX_TOPMOST.0 as i32)
            | (WS_EX_TOOLWINDOW.0 as i32)
            | (WS_EX_NOACTIVATE.0 as i32);
        SetWindowLongW(hwnd, GWL_EXSTYLE, new_style);
    }
}

#[cfg(target_os = "windows")]
pub unsafe fn show_no_activate(hwnd: isize, x: i32, y: i32) {
    let hwnd = HWND(hwnd as *mut _);
    unsafe {
        let _ = ShowWindow(hwnd, SW_SHOWNOACTIVATE);
        let _ = SetWindowPos(
            hwnd,
            Some(HWND_TOPMOST),
            x,
            y,
            0,
            0,
            SWP_NOSIZE | SWP_NOACTIVATE | SWP_SHOWWINDOW,
        );
    }
}

#[cfg(target_os = "windows")]
pub unsafe fn hide_window(hwnd: isize) {
    let hwnd = HWND(hwnd as *mut _);
    unsafe {
        let _ = ShowWindow(hwnd, SW_HIDE);
    }
}

#[cfg(target_os = "windows")]
pub unsafe fn paste_emoji(text: &str) {
    let saved = arboard::Clipboard::new()
        .ok()
        .and_then(|mut c| c.get_text().ok());

    arboard::Clipboard::new()
        .and_then(|mut c| c.set_text(text))
        .ok();

    std::thread::sleep(std::time::Duration::from_millis(10));

    let ctrl = VIRTUAL_KEY(0x11);
    let v = VIRTUAL_KEY(0x56);
    let inputs = [
        keybd(ctrl, KEYBD_EVENT_FLAGS(0)),
        keybd(v, KEYBD_EVENT_FLAGS(0)),
        keybd(v, KEYEVENTF_KEYUP),
        keybd(ctrl, KEYEVENTF_KEYUP),
    ];
    unsafe {
        let _ = SendInput(&inputs, std::mem::size_of::<INPUT>() as i32);
    }

    std::thread::sleep(std::time::Duration::from_millis(50));

    if let Some(prev) = saved {
        arboard::Clipboard::new()
            .and_then(|mut c| c.set_text(prev))
            .ok();
    } else {
        let _ = arboard::Clipboard::new().and_then(|mut c| c.clear());
    }
}

pub unsafe fn paste_gif_file(bytes: &[u8]) {
    let tmp = std::env::temp_dir().join("flemozi_gif");
    let _ = std::fs::create_dir_all(&tmp);
    let stamp = std::time::SystemTime::now()
        .duration_since(std::time::UNIX_EPOCH)
        .unwrap_or_default()
        .as_nanos();
    let path = tmp.join(format!("paste_{stamp}.gif"));
    if std::fs::write(&path, bytes).is_err() {
        return;
    }

    let wide: Vec<u16> = path
        .as_os_str()
        .encode_wide()
        .chain(std::iter::once(0))
        .collect();

    // DROPFILES is 20 bytes: pFiles(u32) + pt.x(i32) + pt.y(i32) + fNC(i32) + fWide(i32)
    const HDR: usize = 20;
    let buf_size = HDR + wide.len() * 2;

    let Ok(h) = (unsafe { GlobalAlloc(GHND, buf_size) }) else {
        let _ = std::fs::remove_file(&path);
        return;
    };
    let ptr = unsafe { GlobalLock(h) } as *mut u8;
    if ptr.is_null() {
        let _ = std::fs::remove_file(&path);
        return;
    }

    let dst = unsafe { std::slice::from_raw_parts_mut(ptr, buf_size) };
    dst[0..4].copy_from_slice(&(HDR as u32).to_ne_bytes());   // pFiles
    dst[16..20].copy_from_slice(&1i32.to_ne_bytes());          // fWide = TRUE (Unicode)
    // pt.x, pt.y, fNC are already zero (GHND zero-inits)

    for (i, &w) in wide.iter().enumerate() {
        let off = HDR + i * 2;
        dst[off..off + 2].copy_from_slice(&w.to_ne_bytes());
    }

    unsafe { GlobalUnlock(h).ok(); }

    unsafe {
        let _ = OpenClipboard(None);
        let _ = EmptyClipboard();
        let _ = SetClipboardData(0x000F, Some(HANDLE(h.0))); // CF_HDROP = 0x000F
        let _ = CloseClipboard();
    }

    std::thread::sleep(std::time::Duration::from_millis(10));
    let ctrl = VIRTUAL_KEY(0x11);
    let v = VIRTUAL_KEY(0x56);
    let inputs = [
        keybd(ctrl, KEYBD_EVENT_FLAGS(0)),
        keybd(v, KEYBD_EVENT_FLAGS(0)),
        keybd(v, KEYEVENTF_KEYUP),
        keybd(ctrl, KEYEVENTF_KEYUP),
    ];
    unsafe {
        let _ = SendInput(&inputs, std::mem::size_of::<INPUT>() as i32);
    }

    std::thread::spawn(move || {
        std::thread::sleep(std::time::Duration::from_secs(15));
        let _ = std::fs::remove_file(&path);
    });
}

#[cfg(target_os = "windows")]
fn keybd(vk: VIRTUAL_KEY, flags: KEYBD_EVENT_FLAGS) -> INPUT {
    INPUT {
        r#type: INPUT_KEYBOARD,
        Anonymous: INPUT_0 {
            ki: KEYBDINPUT {
                wVk: vk,
                wScan: 0,
                dwFlags: flags,
                time: 0,
                dwExtraInfo: 0,
            },
        },
    }
}

#[cfg(not(target_os = "windows"))]
pub fn set_hook_active(_active: bool) {}
#[cfg(not(target_os = "windows"))]
#[allow(dead_code)]
pub fn is_hook_active() -> bool {
    false
}
#[cfg(not(target_os = "windows"))]
pub fn try_recv_hook_key() -> Option<HookKeyEvent> {
    None
}
#[cfg(not(target_os = "windows"))]
pub fn init_keyboard_hook() {}
#[cfg(not(target_os = "windows"))]
pub fn foreground_window() -> isize {
    0
}
#[cfg(not(target_os = "windows"))]
pub fn get_cursor_pos() -> (i32, i32) {
    (0, 0)
}
#[cfg(not(target_os = "windows"))]
pub fn get_screen_size() -> (i32, i32) {
    (0, 0)
}
#[cfg(not(target_os = "windows"))]
pub unsafe fn set_window_style(_hwnd: isize) {}
#[cfg(not(target_os = "windows"))]
pub unsafe fn show_no_activate(_hwnd: isize, _x: i32, _y: i32) {}
#[cfg(not(target_os = "windows"))]
pub unsafe fn hide_window(_hwnd: isize) {}
#[cfg(not(target_os = "windows"))]
pub unsafe fn paste_emoji(_text: &str) {}
#[cfg(not(target_os = "windows"))]
pub unsafe fn paste_gif_file(_bytes: &[u8]) {}
