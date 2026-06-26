pub struct EmoticonEntry {
    pub text: &'static str,
    pub category: &'static str,
}

pub fn filter_emoticons(entries: &[EmoticonEntry], query: &str) -> Vec<usize> {
    let q = query.trim().to_lowercase();

    if q.is_empty() {
        return (0..entries.len()).collect();
    }

    entries
        .iter()
        .enumerate()
        .filter(|(_, e)| {
            e.text.to_lowercase().contains(&q) || e.category.to_lowercase().contains(&q)
        })
        .map(|(i, _)| i)
        .collect()
}
