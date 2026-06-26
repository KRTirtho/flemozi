# Flemozi

Rust + [iced] v0.14 desktop emoji picker. **Windows-only** (global keyboard hook,
`windows` crate, `SendInput` clipboard paste). **Not Flutter** (README is stale).

## Build & Run

```sh
cargo build          # debug
cargo run            # run
cargo build --release
```

Edition 2024 → Rust ≥1.85. No tests, no CI, no linter/formatter config.

## Build-time codegen

`build.rs` scans `assets/twemoji/*.png`, generates `OUT_DIR/twemoji_stems.rs`
(embedded via `include!` in `src/twemoji_stems.rs`). Twemoji PNGs must be present.

## `.env` is stale

`.env.example` asks for `TENOR_API_KEY`/`GIPHY_API_KEY` — leftover from the
Flutter version. Current Rust code does not read `.env`.

## Architecture

| Path | Role |
|---|---|
| `src/main.rs` | Entrypoint: iced app builder |
| `src/app.rs` | State, messages, update & subscription logic |
| `src/ui/` | Widgets (grid, preview, styles) |
| `src/win32.rs` | Win32 FFI: hook, window mgmt, clipboard paste |
| `src/search.rs` | Simple substring/tag matching |
| `src/emoji.rs` | EmojiEntry → Twemoji image resolution |
| `src/assets/emojis.rs` | Static ~3000-entry emoji dataset (codegen from gemoji) |

## Key dependencies

- `iced` 0.14 with `iced::grid(AspectRatio(1.0))`, `window::Id`, `window::run`
- `global-hotkey` 0.8 — registers Ctrl+Alt+.
- `tray-icon` 0.24 — system tray with Show/Exit menu
- `arboard` 3 — clipboard save/restore around `SendInput` Ctrl+V
- `windows` 0.62 — `WH_KEYBOARD_LL`, `SetWindowPos`, `ShowWindow`
- Twemoji images rendered via `iced::widget::image`

## Dev notes

- `cargo build` must be run at the repo root (no monorepo config, no workspace).
- No snapshot or fixture tests. No integration test runner.
- Hotkey hook requires admin elevation on some Windows configs.
- `window_size` suggestion in Cargo.toml is `(500.0, 500.0)`.
