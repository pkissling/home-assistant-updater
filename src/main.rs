#![feature(proc_macro_hygiene, decl_macro)]

mod routes;
mod from_request;
mod config;
mod services;

#[macro_use]
extern crate rocket;

use crate::config::env_vars;
use rocket::config::{Config, Environment};
use services::shell;

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
    // TODO container not gracefully stopping!
    rocket::custom(config)
        .mount(base_url, routes)
        .launch();
}


async fn ensure_preconditions() {
    // API_KEY must be set
    env_vars::expected_api_key();

    // docker must be installed
    shell::exec("docker version").expect("docker cli not installed");
    shell::exec("docker ps").expect("unable to access docker.sock");
}
