use crate::emoji::EmojiEntry;

pub fn filter(entries: &[EmojiEntry], query: &str) -> Vec<usize> {
    let q = query.trim().to_lowercase();

    if q.is_empty() {
        return (0..entries.len()).collect();
    }

    entries
        .iter()
        .enumerate()
        .filter(|(_, e)| {
            e.description.to_lowercase().contains(&q)
                || e.aliases.iter().any(|a| a.to_lowercase().contains(&q))
                || e.tags.iter().any(|t| t.to_lowercase().contains(&q))
                || e.category.to_lowercase().contains(&q)
                || e.emoji.contains(query)
        })
        .map(|(i, _)| i)
        .collect()
}
