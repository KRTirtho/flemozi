use iced::widget::image;

use crate::assets::emojis::EmojiType;
use crate::twemoji_stems::TWEMOJI_STEMS;

#[derive(Debug, Clone)]
pub struct EmojiEntry {
    pub emoji: &'static str,
    pub description: &'static str,
    pub category: &'static str,
    pub aliases: &'static [&'static str],
    pub tags: &'static [&'static str],
    pub image: Option<image::Handle>,
}

impl EmojiEntry {
    pub fn from_type(t: &EmojiType) -> Self {
        let assets = std::env::current_exe()
            .ok()
            .and_then(|p| p.parent().map(|p| p.to_path_buf()))
            .unwrap_or_default()
            .join("assets")
            .join("twemoji");

        let image = twemoji_candidates(t.emoji)
            .into_iter()
            .find(|c| TWEMOJI_STEMS.binary_search(&c.as_str()).is_ok())
            .map(|c| image::Handle::from_path(assets.join(format!("{c}.png"))));

        EmojiEntry {
            emoji: t.emoji,
            description: t.description,
            category: t.category,
            aliases: t.aliases,
            tags: t.tags,
            image,
        }
    }
}

pub fn to_codepoints(emoji: &str) -> String {
    emoji
        .chars()
        .map(|c| format!("{:X}", c as u32))
        .collect::<Vec<_>>()
        .join(" ")
}

fn twemoji_candidates(emoji: &str) -> Vec<String> {
    let codepoints: Vec<u32> = emoji.chars().map(|c| c as u32).collect();
    let has_zwj = codepoints.contains(&0x200D);

    let full: String = codepoints
        .iter()
        .map(|cp| format!("{:04x}", cp))
        .collect::<Vec<_>>()
        .join("-");

    let no_fe0f: String = codepoints
        .iter()
        .filter(|cp| **cp != 0xFE0F)
        .map(|cp| format!("{:04x}", cp))
        .collect::<Vec<_>>()
        .join("-");

    let mut candidates = Vec::new();

    if has_zwj {
        candidates.push(full.clone());
        if no_fe0f != full {
            candidates.push(no_fe0f);
        }
    } else {
        candidates.push(no_fe0f.clone());
        if full != no_fe0f {
            candidates.push(full);
        }
    }

    candidates
}
