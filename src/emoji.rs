use crate::assets::emojis::EmojiType;

#[derive(Debug, Clone)]
pub struct EmojiEntry {
    pub emoji: &'static str,
    pub description: &'static str,
    pub category: &'static str,
    pub aliases: &'static [&'static str],
    pub tags: &'static [&'static str],
}

impl EmojiEntry {
    pub fn from_type(t: &EmojiType) -> Self {
        EmojiEntry {
            emoji: t.emoji,
            description: t.description,
            category: t.category,
            aliases: t.aliases,
            tags: t.tags,
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
