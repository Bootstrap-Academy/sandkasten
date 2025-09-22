# Sandkasten Client
[Sandkasten](https://radicle.defelo.de/nodes/radicle.defelo.de/rad:zKBbWZxz73j7BZMbutM7TMMT4v5K)
client library for running untrusted code

## Example
```rust,no_run
use sandkasten_client::{
    schemas::programs::{BuildRequest, BuildRunRequest, MainFile},
    SandkastenClient,
};

#[tokio::main]
async fn main() {
    let client = SandkastenClient::new("http://your-sandkasten-instance".parse().unwrap());
    let result = client
        .build_and_run(&BuildRunRequest {
            build: BuildRequest {
                environment: "python".into(),
                main_file: MainFile {
                    name: Some("test.py".into()),
                    content: "print(6 * 7, end='')".into(),
                },
                ..Default::default()
            },
            run: Default::default(),
        })
        .await
        .unwrap();
    assert_eq!(result.run.stdout, "42");
}
```
