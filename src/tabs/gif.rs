use std::collections::{HashMap, HashSet};

use iced::widget::{self, operation, scrollable};
use iced::Task as Command;
use serde::Deserialize;

use crate::app::{COLUMNS, Message, Move, SPACING, SearchState};

const API_BASE: &str = "https://api.giphy.com/v1/gifs";

#[derive(Debug, Clone)]
#[allow(dead_code)]
pub struct GifEntry {
    pub id: String,
    pub url: String,
    pub gif_url: String,
    pub preview_url: String,
    pub slug: String,
    pub rating: String,
}

pub struct GifTab {
    pub entries: Vec<GifEntry>,
    pub frames: HashMap<usize, iced_gif::Frames>,
    pub filtered: Vec<usize>,
    pub selected: usize,
    pub visible: HashSet<usize>,
    pub loading_frames: HashSet<usize>,
    pub scroll_id: widget::Id,
    pub saved_search: SearchState,
    pub loading: bool,
    pub error: Option<String>,
}

fn move_in(filtered: &[usize], selected: &mut usize, mv: Move) -> bool {
    if filtered.is_empty() {
        return false;
    }

    let pos = filtered.iter().position(|&i| i == *selected).unwrap_or(0);
    let len = filtered.len();
    let next = match mv {
        Move::Up => pos.saturating_sub(COLUMNS),
        Move::Down => (pos + COLUMNS).min(len - 1),
        Move::Left => pos.saturating_sub(1),
        Move::Right => (pos + 1).min(len - 1),
    };

    let old_row = pos / COLUMNS;
    let new_row = next / COLUMNS;
    *selected = filtered[next];
    old_row != new_row
}

fn scroll_y(filtered: &[usize], selected: usize) -> f32 {
    let pos = filtered.iter().position(|&i| i == selected).unwrap_or(0);
    let row = pos / COLUMNS;
    let content_width = 500.0 - 42.0 - 24.0;
    let gaps = (COLUMNS - 1) as f32 * SPACING;
    let cell_width = (content_width - gaps) / COLUMNS as f32;
    let row_height = cell_width + SPACING;
    row as f32 * row_height
}

impl GifTab {
    pub fn new() -> Self {
        Self {
            entries: Vec::new(),
            frames: HashMap::new(),
            filtered: Vec::new(),
            selected: 0,
            visible: HashSet::new(),
            loading_frames: HashSet::new(),
            scroll_id: "gif-scroll".into(),
            saved_search: SearchState::new(),
            loading: true,
            error: None,
        }
    }

    pub fn set_entries(&mut self, entries: Vec<GifEntry>) {
        self.entries = entries;
        self.filtered = (0..self.entries.len()).collect();
        self.selected = self.filtered.first().copied().unwrap_or(0);
        self.loading = false;
        self.error = None;
        self.frames.clear();
        self.loading_frames.clear();
    }

    pub fn set_error(&mut self, msg: String) {
        self.entries.clear();
        self.filtered.clear();
        self.loading = false;
        self.error = Some(msg);
    }

    pub fn apply_search(&mut self, query: &str) -> bool {
        let q = query.trim().to_lowercase();

        if q.is_empty() {
            self.filtered = (0..self.entries.len()).collect();
            self.selected = self.filtered.first().copied().unwrap_or(0);
            return self.entries.is_empty();
        }

        self.filtered = self
            .entries
            .iter()
            .enumerate()
            .filter(|(_, e)| e.slug.to_lowercase().contains(&q))
            .map(|(i, _)| i)
            .collect();
        self.selected = self.filtered.first().copied().unwrap_or(0);
        self.filtered.is_empty()
    }

    pub fn move_selection(&mut self, mv: Move) -> bool {
        move_in(&self.filtered, &mut self.selected, mv)
    }

    pub fn scroll_to_selected(&self) -> Command<Message> {
        if self.filtered.is_empty() {
            return Command::none();
        }
        let y = scroll_y(&self.filtered, self.selected);
        operation::scroll_to(
            self.scroll_id.clone(),
            scrollable::AbsoluteOffset { x: 0.0, y },
        )
    }

    pub fn copy_text(&self) -> Option<String> {
        let entry = self.entries.get(self.selected)?;
        if !self.filtered.contains(&self.selected) {
            return None;
        }
        Some(entry.gif_url.clone())
    }
}

// ── Minimal Giphy API response types ──

#[derive(Deserialize)]
struct GiphyResponse {
    data: Vec<GiphyGif>,
    meta: GiphyMeta,
}

#[derive(Deserialize)]
struct GiphyMeta {
    status: i64,
    msg: String,
}

#[derive(Deserialize)]
struct GiphyGif {
    id: String,
    url: String,
    slug: String,
    rating: String,
    images: GiphyImages,
}

#[derive(Deserialize)]
struct GiphyImages {
    downsized: Option<GiphyImage>,
    downsized_still: Option<GiphyImage>,
    fixed_width_small: Option<GiphyImage>,
    original: Option<GiphyImage>,
}

#[derive(Deserialize)]
struct GiphyImage {
    url: String,
}

// ── HTTP helpers ──

fn api_key() -> Result<String, String> {
    crate::env::giphy_api_key()
        .ok_or_else(|| "GIPHY_API_KEY not set (missing from .env at build time)".to_string())
}

async fn get(path: &str, params: &[(&str, &str)]) -> Result<Vec<GifEntry>, String> {
    let key = api_key()?;
    let url = reqwest::Url::parse_with_params(
        &format!("{API_BASE}{path}"),
        std::iter::once(&("api_key", key.as_str())).chain(params),
    )
    .map_err(|e| format!("invalid URL: {e}"))?;

    let resp = reqwest::get(url)
        .await
        .map_err(|e| format!("HTTP request failed: {e}"))?;

    let status = resp.status();
    if !status.is_success() {
        let body = resp.text().await.unwrap_or_default();
        return Err(format!("Giphy API returned {status}: {body}"));
    }

    let body: GiphyResponse = resp
        .json()
        .await
        .map_err(|e| format!("JSON parse failed: {e}"))?;

    if body.meta.status != 200 {
        return Err(format!("Giphy API error: {} ({})", body.meta.msg, body.meta.status));
    }

    Ok(body
        .data
        .into_iter()
        .map(|g| GifEntry {
            id: g.id,
            url: g.url,
            gif_url: g
                .images
                .original
                .or(g.images.downsized)
                .map(|i| i.url)
                .unwrap_or_default(),
            preview_url: g
                .images
                .fixed_width_small
                .or(g.images.downsized_still)
                .map(|i| i.url)
                .unwrap_or_default(),
            slug: g.slug,
            rating: g.rating,
        })
        .collect())
}

pub async fn download_image(url: String) -> Vec<u8> {
    let Ok(resp) = reqwest::get(&url).await else {
        return Vec::new();
    };
    resp.bytes().await.map(|b| b.to_vec()).unwrap_or_default()
}

pub async fn fetch_trending_gifs() -> Result<Vec<GifEntry>, String> {
    let result = get("/trending", &[("limit", "50"), ("offset", "0"), ("rating", "g")]).await;
    if let Err(ref e) = result {
        tracing::error!("Giphy trending failed: {e}");
    }
    result
}

pub async fn search_gifs(query: String) -> Result<Vec<GifEntry>, String> {
    let q = query.trim().to_lowercase();
    if q.is_empty() {
        return fetch_trending_gifs().await;
    }
    let result = get(
        "/search",
        &[
            ("q", &q),
            ("limit", "50"),
            ("offset", "0"),
            ("rating", "g"),
            ("lang", "en"),
        ],
    )
    .await;
    if let Err(ref e) = result {
        tracing::error!("Giphy search failed: {e}");
    }
    result
}
