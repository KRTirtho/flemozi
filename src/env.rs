include!(concat!(env!("OUT_DIR"), "/env_vars.rs"));

pub fn giphy_api_key() -> Option<String> {
    get("GIPHY_API_KEY").or_else(|| std::env::var("GIPHY_API_KEY").ok())
}
