use anyhow::Result;

use std::mem::size_of;
use std::thread;
use std::time::Duration;
use crate::frb_generated::StreamSink;

use windows::core::Interface; // Required for object .cast() methods
use windows::Win32::Foundation::{HWND, RECT};
use windows::Win32::System::Com::{CoInitializeEx, CoCreateInstance, COINIT_APARTMENTTHREADED, CLSCTX_INPROC_SERVER};
use windows::Win32::System::Ole::{SafeArrayAccessData, SafeArrayUnaccessData, SafeArrayDestroy};
use windows::Win32::UI::Accessibility::{
    CUIAutomation, IUIAutomation, IUIAutomationElement, IUIAutomationTextPattern, 
    IUIAutomationTextRangeArray, IUIAutomationTextRange, UIA_TextPatternId,
};
use windows::Win32::UI::WindowsAndMessaging::{
    GetForegroundWindow, GetGUIThreadInfo, GetWindowThreadProcessId, 
    GUITHREADINFO, GUITHREADINFO_FLAGS, GUI_CARETBLINKING,
};

/// This function will be exposed to Dart via flutter_rust_bridge
pub fn inject_emoji(emoji: String, target_hwnd_raw: i64) -> Result<(), String> {
    #[cfg(target_os = "windows")]
    {
        inject_windows_targeted(&emoji, target_hwnd_raw).map_err(|e| e.to_string())?;
    }

    Ok(())
}

#[derive(Debug, Clone)]
pub struct CaretInfo {
    pub hwnd: i64,
    pub left: i32,
    pub top: i32,
    pub right: i32,
    pub bottom: i32,
}

pub fn start_caret_monitor(sink: StreamSink<CaretInfo>, flutter_hwnd_raw: i64) {
    thread::spawn(move || unsafe {
        let _ = CoInitializeEx(None, COINIT_APARTMENTTHREADED);
        
        // Fix 1: Pull CoCreateInstance directly from Win32::System::Com
        let uia: Option<IUIAutomation> = CoCreateInstance(&CUIAutomation, None, CLSCTX_INPROC_SERVER).ok();

        let my_flutter_hwnd = HWND(flutter_hwnd_raw as *mut std::ffi::c_void);

        loop {
            let hwnd_foreground = GetForegroundWindow();

            if hwnd_foreground.is_invalid() || hwnd_foreground == my_flutter_hwnd {
                thread::sleep(Duration::from_millis(60));
                continue;
            }

            let thread_id = GetWindowThreadProcessId(hwnd_foreground, None);
            let mut gui_info = GUITHREADINFO {
                cbSize: size_of::<GUITHREADINFO>() as u32,
                ..Default::default()
            };

            let mut caret_found = false;
            let mut final_rect = RECT::default();

            // --- STRATEGY 1: Win32 Legacy Fallback ---
            if GetGUIThreadInfo(thread_id, &mut gui_info).is_ok() {
                let has_caret = (gui_info.flags & GUITHREADINFO_FLAGS(GUI_CARETBLINKING.0)) != GUITHREADINFO_FLAGS(0)
                    || gui_info.rcCaret != RECT::default();

                if has_caret && gui_info.rcCaret.left != 0 {
                    final_rect = gui_info.rcCaret;
                    caret_found = true;
                }
            }

            // --- STRATEGY 2: Modern UI Automation Fallback ---
            if !caret_found {
                if let Some(ref uia_client) = uia {
                    // Added explicit types here to eliminate all "type annotations needed" errors
                    if let Ok(focused_element) = uia_client.GetFocusedElement() {
                        let focused_element: IUIAutomationElement = focused_element;

                        // Fix 2: Pass UIA_TextPatternId directly without the `.0` primitive extraction
                        if let Ok(pattern) = focused_element.GetCurrentPattern(UIA_TextPatternId) {
                            let pattern: windows::core::IUnknown = pattern;

                            // Fix 3: Remove inline UIAutomation block and use clean UI::Accessibility path
                            if let Ok(uia_text) = pattern.cast::<IUIAutomationTextPattern>() {
                                let uia_text: IUIAutomationTextPattern = uia_text;

                                if let Ok(selection) = uia_text.GetSelection() {
                                    let selection: IUIAutomationTextRangeArray = selection;

                                    if let Ok(count) = selection.Length() {
                                        let count: i32 = count;

                                        if count > 0 {
                                            if let Ok(range) = selection.GetElement(0) {
                                                let range: IUIAutomationTextRange = range;
                                                
                                                // Fix 4: Safely query, access, map, and unlock raw safe arrays natively
                                                if let Ok(sa_rects) = range.GetBoundingRectangles() {
                                                    let mut p_data: *mut std::ffi::c_void = std::ptr::null_mut();
                                                    
                                                    if SafeArrayAccessData(sa_rects, &mut p_data).is_ok() {
                                                        let slice = std::slice::from_raw_parts(p_data as *const f64, 4);
                                                        if slice.len() >= 4 {
                                                            final_rect = RECT {
                                                                left: slice[0] as i32,
                                                                top: slice[1] as i32,
                                                                right: (slice[0] + slice[2]) as i32,
                                                                bottom: (slice[1] + slice[3]) as i32,
                                                            };
                                                            caret_found = true;
                                                        }
                                                        let _ = SafeArrayUnaccessData(sa_rects);
                                                    }
                                                    // Always destroy the COM-allocated safe array once extracted to avoid leaks
                                                    let _ = SafeArrayDestroy(sa_rects);
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            if caret_found {
                let info = CaretInfo {
                    hwnd: hwnd_foreground.0 as i64,
                    left: final_rect.left,
                    top: final_rect.top,
                    right: final_rect.right,
                    bottom: final_rect.bottom,
                };
                
                if sink.add(info).is_err() {
                    break; 
                }
            }

            thread::sleep(Duration::from_millis(60));
        }
    });
}

#[cfg(target_os = "windows")]
fn inject_windows_targeted(emoji: &str, target_hwnd_raw: i64) -> Result<()> {
    let hwnd_target = HWND(target_hwnd_raw as *mut std::ffi::c_void);
    
    if hwnd_target.is_invalid() {
        return Err(anyhow::anyhow!("Invalid target window handle"));
    }

    unsafe {
        // Breakdown the emoji into its UTF-16 surrogate components
        for unit in emoji.encode_utf16() {
            // PostMessageW delivers directly to this handle without manipulating system focus

            use windows::Win32::{Foundation::{LPARAM, WPARAM}, UI::WindowsAndMessaging::{PostMessageW, WM_CHAR}};
            let result = PostMessageW(
                Some(hwnd_target), 
                WM_CHAR, 
                WPARAM(unit as usize), 
                LPARAM(1) // Repeat count = 1
            );
            if result.is_err() {
                return Err(anyhow::anyhow!("Failed to post window message"));
            }
        }
    }
    Ok(())
}