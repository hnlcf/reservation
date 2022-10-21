use std::{fs, io, process::Command};

fn main() -> io::Result<()> {
    tonic_build::configure()
        .out_dir("src/pb")
        .compile(&["protos/reservation.proto"], &["protos"])?;

    fs::remove_file("src/pb/google.protobuf.rs")?;

    Command::new("cargo")
        .args(["fmt"])
        .output()
        .expect("Failed to format proto files");

    println!("cargo:rerun-if-changed=protos/reservation.proto");

    Ok(())
}
