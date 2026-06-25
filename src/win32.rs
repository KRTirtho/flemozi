#[cfg(target_os = "windows")]
use windows::Win32::UI::Input::KeyboardAndMouse::{
    SendInput, INPUT, INPUT_0, INPUT_KEYBOARD, KEYBDINPUT,
    KEYBD_EVENT_FLAGS, KEYEVENTF_KEYUP, VIRTUAL_KEY,
};
#[cfg(target_os = "windows")]
use windows::Win32::UI::WindowsAndMessaging::{
    GetForegroundWindow, SetForegroundWindow, GetWindowLongW, SetWindowLongW,
    ShowWindow, SetWindowPos, GWL_EXSTYLE, WS_EX_TOPMOST, WS_EX_TOOLWINDOW,
    SW_SHOWNOACTIVATE, SWP_NOMOVE, SWP_NOSIZE, SWP_NOACTIVATE, SWP_SHOWWINDOW,
    HWND_TOPMOST,
};
#[cfg(target_os = "windows")]
use windows::Win32::Foundation::HWND;

#[cfg(target_os = "windows")]
pub fn foreground_window() -> isize {
    unsafe { GetForegroundWindow().0 as isize }
}

#[cfg(target_os = "windows")]
pub unsafe fn set_window_style(hwnd: isize) {
    let hwnd = HWND(hwnd as *mut _);
    unsafe {
        let style = GetWindowLongW(hwnd, GWL_EXSTYLE);
        let new_style = style | (WS_EX_TOPMOST.0 as i32) | (WS_EX_TOOLWINDOW.0 as i32);
        SetWindowLongW(hwnd, GWL_EXSTYLE, new_style);
    }
}

#[cfg(target_os = "windows")]
pub unsafe fn show_no_activate(hwnd: isize) {
    let hwnd = HWND(hwnd as *mut _);
    unsafe {
        let _ = ShowWindow(hwnd, SW_SHOWNOACTIVATE);
        let _ = SetWindowPos(
            hwnd,
            Some(HWND_TOPMOST),
            0, 0, 0, 0,
            SWP_NOMOVE | SWP_NOSIZE | SWP_NOACTIVATE | SWP_SHOWWINDOW,
        );
    }
}

#[cfg(target_os = "windows")]
pub unsafe fn paste_emoji(target_hwnd: isize, text: &str) {
    if target_hwnd == 0 {
        return;
    }

    let saved = arboard::Clipboard::new().ok().and_then(|mut c| c.get_text().ok());

    arboard::Clipboard::new()
        .and_then(|mut c| c.set_text(text))
        .ok();

    std::thread::sleep(std::time::Duration::from_millis(10));

    let hwnd = HWND(target_hwnd as *mut _);
    unsafe { let _ = SetForegroundWindow(hwnd); }
    std::thread::sleep(std::time::Duration::from_millis(50));

    let ctrl = VIRTUAL_KEY(0x11);
    let v = VIRTUAL_KEY(0x56);
    let inputs = [
        keybd(ctrl, KEYBD_EVENT_FLAGS(0)),
        keybd(v, KEYBD_EVENT_FLAGS(0)),
        keybd(v, KEYEVENTF_KEYUP),
        keybd(ctrl, KEYEVENTF_KEYUP),
    ];
    unsafe { let _ = SendInput(&inputs, std::mem::size_of::<INPUT>() as i32); }

    std::thread::sleep(std::time::Duration::from_millis(150));

    if let Some(prev) = saved {
        arboard::Clipboard::new()
            .and_then(|mut c| c.set_text(prev))
            .ok();
    } else {
        let _ = arboard::Clipboard::new().and_then(|mut c| c.clear());
    }
}

#[cfg(target_os = "windows")]
fn keybd(vk: VIRTUAL_KEY, flags: KEYBD_EVENT_FLAGS) -> INPUT {
    INPUT {
        r#type: INPUT_KEYBOARD,
        Anonymous: INPUT_0 {
            ki: KEYBDINPUT { wVk: vk, wScan: 0, dwFlags: flags, time: 0, dwExtraInfo: 0 },
        },
    }
}

#[cfg(not(target_os = "windows"))]
pub fn foreground_window() -> isize { 0 }
#[cfg(not(target_os = "windows"))]
pub unsafe fn set_window_style(_hwnd: isize) {}
#[cfg(not(target_os = "windows"))]
pub unsafe fn show_no_activate(_hwnd: isize) {}
#[cfg(not(target_os = "windows"))]
pub unsafe fn paste_emoji(_target_hwnd: isize, _text: &str) {}
