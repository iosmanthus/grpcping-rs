use grpcio::{ChannelBuilder, ChannelCredentialsBuilder, Environment};
use grpcio_health::{proto::HealthCheckRequest, HealthClient};
use std::{fs::File, io::Read, path::Path, sync::Arc};

fn load_key<P: AsRef<Path>>(path: P) -> Vec<u8> {
    let mut buf = Vec::new();
    let _ = File::open(path).unwrap().read_to_end(&mut buf).unwrap();
    buf
}

fn main() {
    let args: Vec<String> = std::env::args().collect();
    let (addr, ca_path, cert_path, key_path) = (&args[1], &args[2], &args[3], &args[4]);
    let env = Arc::new(Environment::new(1));

    println!("grpc: connect to {}", addr);
    let channel = ChannelBuilder::new(env.clone()).connect(addr);
    let client = HealthClient::new(channel);
    let resp = client.check(&HealthCheckRequest::new());
    if resp.is_ok() {
        println!("ok");
    } else {
        println!("resp: {:?}", resp);
    }

    println!("grpc+tls: connect to {}", addr);
    let ca = load_key(ca_path);
    let cert = load_key(cert_path);
    let key = load_key(key_path);
    let cred = ChannelCredentialsBuilder::new()
        .root_cert(ca)
        .cert(cert, key)
        .build();
    let channel = ChannelBuilder::new(env).secure_connect(addr, cred);
    let client = HealthClient::new(channel);
    let resp = client.check(&HealthCheckRequest::new());
    if resp.is_ok() {
        println!("ok");
    } else {
        println!("resp: {:?}", resp);
    }

}
