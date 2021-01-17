use rocket::http::Status;
use rocket::request::{FromRequest, Outcome};
use rocket::Request;

use crate::config::env_vars;

pub struct ApiKey {
    pub value: String,
}

impl ApiKey {
    fn new(value: &str) -> Self {
        ApiKey { value: value.to_string() }
    }
}

impl<'a, 'r> FromRequest<'a, 'r> for ApiKey {
    type Error = String;

    fn from_request(request: &'a Request<'r>) -> Outcome<ApiKey, String> {
        request
            .headers()
            .get_one("X-API-KEY")
            .filter(|api_key| api_key == &env_vars::expected_api_key())
            .map(|api_key| ApiKey::new(api_key))
            .map_or_else(
                || Outcome::Failure((Status::Unauthorized, String::from("No or invalid X-API-Key provided."))),
                |k| Outcome::Success(k),
            )
    }
}
