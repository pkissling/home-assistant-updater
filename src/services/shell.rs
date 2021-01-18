use std::process::{Command, Output};
use std::str;
use crate::routes::update_container::HttpStatusCode;

pub fn exec(cmd: &str) -> Result<String, HttpStatusCode> {
    println!("exec: {}", cmd);
    let cmd = format!("{} > /dev/null", cmd);
    let output = Command::new("sh")
        .arg("-c")
        .arg(cmd)
        .output() // TODO use output()?
        .expect("failed");

    println!("status: {}", output.status.code().unwrap());
    match output.status.success() {
        true => {
            if !output.stdout.is_empty() {
                println!("stdout: {}", str::from_utf8(&output.stdout).unwrap())
            }
        }
        false => println!("stdout: {}", str::from_utf8(&output.stderr).unwrap())
    }


    wrap(output)
}

fn wrap(o: Output) -> Result<String, HttpStatusCode> {
    let msg = match o.status.success() {
        true => str::from_utf8(&o.stdout).unwrap_or(""),
        false => str::from_utf8(&o.stderr).unwrap_or("")
    };

    match o.status.success() {
        true => Ok(String::from(msg)),
        false => Err(HttpStatusCode::new(500, String::from(msg)))
    }
}

