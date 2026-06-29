use std::collections::BTreeSet;
use std::env;
use std::fs;
use std::path::PathBuf;

#[cfg(target_os = "windows")]
fn embed_icon() {
    let mut res = winres::WindowsResource::new();
    res.set_icon("assets/icon.ico");
    let _ = res.compile();
}

#[cfg(not(target_os = "windows"))]
fn embed_icon() {}

fn main() {
    embed_icon();

    #[cfg(target_os = "macos")]
    println!("cargo:rustc-link-lib=framework=CoreGraphics");

    #[cfg(target_os = "macos")]
    println!("cargo:rustc-link-lib=framework=ApplicationServices");

    println!("cargo:rerun-if-changed=assets/twemoji");
    println!("cargo:rerun-if-changed=.env");

    let manifest = PathBuf::from(env::var("CARGO_MANIFEST_DIR").unwrap());
    let out_dir = env::var("OUT_DIR").unwrap();

    // ── twemoji stems ──
    let dir = manifest.join("assets/twemoji");
    let mut stems: BTreeSet<String> = BTreeSet::new();
    if let Ok(entries) = fs::read_dir(&dir) {
        for entry in entries.flatten() {
            if let Some(stem) = entry.path().file_stem().and_then(|s| s.to_str()) {
                stems.insert(stem.to_lowercase());
            }
        }
    }
    let dest = PathBuf::from(&out_dir).join("twemoji_stems.rs");
    let mut content = String::from("pub const TWEMOJI_STEMS: &[&str] = &[\n");
    for stem in &stems {
        content.push_str(&format!("    \"{stem}\",\n"));
    }
    content.push_str("];\n");
    fs::write(&dest, content).unwrap();

    // ── obfuscated env vars (envied-style) ──
    let env_path = manifest.join(".env");
    let env_dest = PathBuf::from(&out_dir).join("env_vars.rs");

    let mut arms = String::new();
    let mut count = 0u32;

    if let Ok(text) = fs::read_to_string(&env_path) {
        for line in text.lines() {
            let line = line.trim();
            if line.is_empty() || line.starts_with('#') {
                continue;
            }
            if let Some(eq) = line.find('=') {
                let name = line[..eq].trim();
                let value = line[eq + 1..].trim();

                let val_bytes: Vec<u8> = value.bytes().collect();
                let xor_key: Vec<u8> = (0..32).map(|i| rand_byte(count, i)).collect();
                let obfuscated: Vec<u8> = val_bytes
                    .iter()
                    .enumerate()
                    .map(|(i, b)| b ^ xor_key[i % xor_key.len()])
                    .collect();

                arms.push_str(&format!(
                    r#"        "{name}" => Some({{
            static KEY: &[u8] = &{:?};
            static DATA: &[u8] = &{:?};
            String::from_utf8(DATA.iter().enumerate().map(|(i, b)| b ^ KEY[i % KEY.len()]).collect()).unwrap()
        }}),
"#,
                    xor_key, obfuscated,
                ));
                count += 1;
            }
        }
    }

    let content = format!(
        r#"pub(crate) fn get(key: &str) -> Option<String> {{
    match key {{
{arms}        _ => None,
    }}
}}
"#,
    );

    fs::write(&env_dest, content).unwrap();
}

fn rand_byte(seed: u32, idx: u32) -> u8 {
    use std::hash::{Hash, Hasher};
    let mut h = std::collections::hash_map::DefaultHasher::new();
    (seed, idx).hash(&mut h);
    (h.finish() & 0xFF) as u8
}
