use std::env;

pub fn expected_api_key() -> String {
    env::var("API_KEY").expect("'API_KEY' not set")
}
