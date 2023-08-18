// Prevents additional console window on Windows in release, DO NOT REMOVE!!
#![cfg_attr(not(debug_assertions), windows_subsystem = "windows")]

use serde_json::Value;
use tauri::Manager;
use tauri_plugin_autostart::MacosLauncher;

fn main() {
    tauri::Builder::default()
        .plugin(tauri_plugin_window_state::Builder::default().build())
        .plugin(tauri_plugin_autostart::init(
            MacosLauncher::LaunchAgent,
            Some(vec!["--headless"]),
        ))
        .plugin(tauri_plugin_single_instance::init(|app, _, _| {
            app.emit_all("showWindow", ()).unwrap();
        }))
        .setup(|app| {
            // hide the window if include --headless
            if let Ok(matches) = app.get_cli_matches() {
                if matches.args.contains_key("headless") {
                    if let Value::Bool(true) = matches.args.get("headless").unwrap().value {
                        app.get_window("main").unwrap().hide().unwrap();
                    }
                }
            }

            Ok(())
        })
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}
