#![feature(proc_macro_hygiene, decl_macro)]

mod routes;
mod from_request;
mod config;
mod services;

#[macro_use]
extern crate rocket;

use crate::config::env_vars;
use rocket::config::{Config, Environment};

fn main() {

    ensure_preconditions();

    let routes = routes![routes::update_container::update_container];
    let base_url = "/";

    let config = Config::build(Environment::Production)
        .address("0.0.0.0")
        .port(5000)
        .finalize()
        .expect("failed");


    // TODo docker system prune -a
    rocket::custom(config)
        .mount(base_url, routes)
        .launch();
}

fn ensure_preconditions() {
    env_vars::expected_api_key();
}
