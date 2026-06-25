use std::collections::BTreeSet;
use std::env;
use std::fs;
use std::path::PathBuf;

fn main() {
    println!("cargo:rerun-if-changed=assets/twemoji");

    let manifest = PathBuf::from(env::var("CARGO_MANIFEST_DIR").unwrap());
    let dir = manifest.join("assets/twemoji");

    let mut stems: BTreeSet<String> = BTreeSet::new();
    if let Ok(entries) = fs::read_dir(&dir) {
        for entry in entries.flatten() {
            if let Some(stem) = entry.path().file_stem().and_then(|s| s.to_str()) {
                stems.insert(stem.to_lowercase());
            }
        }
    }

    let out_dir = env::var("OUT_DIR").unwrap();
    let dest = PathBuf::from(out_dir).join("twemoji_stems.rs");

    let mut content = String::from("pub const TWEMOJI_STEMS: &[&str] = &[\n");
    for stem in &stems {
        content.push_str(&format!("    \"{stem}\",\n"));
    }
    content.push_str("];\n");

    fs::write(&dest, content).unwrap();
}
