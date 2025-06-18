use indoc::formatdoc;
use sandkasten_client::schemas::programs::{
    BuildRequest, BuildRunRequest, LimitsOpt, MainFile, RunRequest,
};

use crate::{client, tests};

tests! {
    test_no_internet,
    test_forkbomb,
    test_stdoutbomb,
    test_flood_memory,
    test_combination,
    test_large_file,
    test_many_files,
}

fn test_no_internet() {
    let response = client()
        .build_and_run(&BuildRunRequest {
            build: BuildRequest {
                environment: "python".into(),
                main_file: MainFile {
                    name: Some("test.py".into()),
                    content: formatdoc! {r#"
                        from http.client import *
                        c=HTTPConnection("127.0.0.1")
                        c.request("GET", "http://127.0.0.1/")
                    "#},
                },
                ..Default::default()
            },
            run: RunRequest {
                run_limits: LimitsOpt {
                    network: Some(false),
                    ..Default::default()
                },
                ..Default::default()
            },
        })
        .unwrap();
    assert_eq!(response.run.status, 1);
    assert_eq!(
        response.run.stderr.trim().lines().last().unwrap(),
        "ConnectionRefusedError: [Errno 111] Connection refused"
    );
}

fn test_forkbomb() {
    let response = client()
        .build_and_run(&BuildRunRequest {
            build: BuildRequest {
                environment: "python".into(),
                main_file: MainFile {
                    name: Some("test.py".into()),
                    content: formatdoc! {"
                        import os
                        while True:
                            os.fork()
                    "},
                },
                ..Default::default()
            },
            run: Default::default(),
        })
        .unwrap();
    dbg!(&response);
    let expected = match response.run.status {
        1 => "Killed",
        137 => "Resource temporarily unavailable",
        _ => panic!(),
    };
    assert!(response.run.stderr.contains(expected));
    assert!(response.run.resource_usage.time < 2000);
}

fn test_stdoutbomb() {
    let response = client()
        .build_and_run(&BuildRunRequest {
            build: BuildRequest {
                environment: "rust".into(),
                main_file: MainFile {
                    name: Some("test.rs".into()),
                    content: formatdoc! {r#"
                        fn main() {{
                            loop {{
                                println!("spam");
                                eprintln!("maps");
                            }}
                        }}
                    "#},
                },
                ..Default::default()
            },
            run: RunRequest {
                run_limits: LimitsOpt {
                    time: Some(1),
                    stdout_max_size: Some(2048),
                    stderr_max_size: Some(1024),
                    ..Default::default()
                },
                ..Default::default()
            },
        })
        .unwrap();
    assert_eq!(response.run.status, 137);
    assert!(response.run.stdout.len() <= 2048);
    assert!(response.run.stderr.len() <= 1024);
}

fn test_flood_memory() {
    let response = client()
        .build_and_run(&BuildRunRequest {
            build: BuildRequest {
                environment: "python".into(),
                main_file: MainFile {
                    name: Some("test.py".into()),
                    content: formatdoc! {r#"
                        x = [1]
                        while True:
                            x += x
                    "#},
                },
                ..Default::default()
            },
            run: RunRequest {
                run_limits: LimitsOpt {
                    memory: Some(256),
                    ..Default::default()
                },
                ..Default::default()
            },
        })
        .unwrap();
    assert_ne!(response.run.status, 0);
    assert!(response.run.stderr.contains("Killed"));
}

fn test_combination() {
    let response = client()
        .build_and_run(&BuildRunRequest {
            build: BuildRequest {
                environment: "python".into(),
                main_file: MainFile {
                    name: Some("test.py".into()),
                    content: formatdoc! {r#"
                        import os
                        for _ in range(10):
                            os.fork()
                        x = [1]
                        while True:
                            x += x
                    "#},
                },
                ..Default::default()
            },
            run: RunRequest {
                run_limits: LimitsOpt {
                    memory: Some(256),
                    processes: Some(16),
                    ..Default::default()
                },
                ..Default::default()
            },
        })
        .unwrap();
    assert_ne!(response.run.status, 0);
    let stderr = response.run.stderr;
    assert!(stderr.contains("MemoryError") || stderr.contains("Resource temporarily unavailable"));
}

fn test_large_file() {
    let response = client()
        .build_and_run(&BuildRunRequest {
            build: BuildRequest {
                environment: "bash".into(),
                main_file: MainFile {
                    name: Some("test.sh".into()),
                    content: formatdoc! {r#"
                        dd if=/dev/urandom of=/tmp/test
                    "#},
                },
                ..Default::default()
            },
            run: Default::default(),
        })
        .unwrap();
    assert_eq!(response.run.status, 153);
    assert!(response.run.stderr.contains("File size limit exceeded"));
}

fn test_many_files() {
    let response = client()
        .build_and_run(&BuildRunRequest {
            build: BuildRequest {
                environment: "bash".into(),
                main_file: MainFile {
                    name: Some("test.sh".into()),
                    content: formatdoc! {r#"
                        cd /tmp
                        i=0
                        while true; do
                            dd if=/dev/urandom of=f$i bs=1M count=16 status=none
                            i=$((i+1))
                        done
                    "#},
                },
                ..Default::default()
            },
            run: Default::default(),
        })
        .unwrap();
    dbg!(&response);
    assert_eq!(response.run.status, 137);
    assert!(response.run.stderr.contains("Killed"));
}
