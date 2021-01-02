use std::process::Output;
use std::str;

use crate::from_request::api_key::ApiKey;
use crate::services::shell;

// TODO create trait which allows mapping errors to http status.
// TODO when error is returned from function, translate to http errror
#[put("/containers/<container_name>")]
pub fn update_container(container_name: String, _api_key: ApiKey) {
    println!("START: Update [{}]", container_name);
    let result = container_exists(&container_name);
    if result.is_err() {
        panic!("404") // todo how to 404?
    }

    let result = update(&container_name);
    if result.is_err() {
        panic!("blubb")
    }

    println!("END: Update [{}]", container_name);
}

fn update(container_name: &String) -> Result<String, HttpStatusCode> {
    let cmd = format!("docker run \
                --rm \
                --name watchtower  \
                --volume /var/run/docker.sock:/var/run/docker.sock \
                containrrr/watchtower \
                --debug \
                --run-once \
                {}", container_name);
    shell::exec(&cmd)
}

fn container_exists(container_name: &String) -> Result<String, HttpStatusCode> {
    let cmd = format!("docker ps -a | grep {}", container_name);
    shell::exec(&cmd)
}

pub struct HttpStatusCode {
    value: i16,
    msg: String,
}

impl HttpStatusCode {
    pub fn new(value: i16, msg: String) -> Self {
        HttpStatusCode { value, msg }
    }
}

impl From<Output> for HttpStatusCode {
    fn from(o: Output) -> HttpStatusCode {
        let msg = match o.status.success() {
            true => {
                if !o.stdout.is_empty() {
                    str::from_utf8(&o.stdout).unwrap().to_string()
                } else {
                    String::from("success")
                }
            }
            false => str::from_utf8(&o.stderr).unwrap().to_string()
        };

        let value = match o.status.success() {
            true => 200,
            false => 500
        };

        HttpStatusCode { value, msg }
    }
}