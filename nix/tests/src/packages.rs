use std::sync::LazyLock;

use sandkasten_client::schemas::{
    environments::{Environment, Test},
    programs::{BuildRequest, BuildRunRequest, BuildRunResult, File, MainFile, RunRequest},
};

use crate::{client, TestCollection, TestFn, ENVIRONMENTS};

pub static TESTS: LazyLock<TestCollection> = LazyLock::new(|| {
    let mut environments = ENVIRONMENTS.iter().collect::<Vec<_>>();
    environments.sort_by_key(|&(id, _)| id);
    environments
        .into_iter()
        .flat_map(|(id, environment)| {
            environment
                .test
                .as_ref()
                .map(|test| {
                    (
                        format!("{}::test_{id}", module_path!()),
                        Box::new(|| test_package(id, environment, test)) as TestFn,
                    )
                })
                .into_iter()
                .chain([(
                    format!("{}::example_{id}", module_path!()),
                    Box::new(|| test_example(id, environment)) as TestFn,
                )])
        })
        .collect()
});

fn test_package(id: &str, environment: &Environment, test: &Test) {
    match dbg!(client().build_and_run(&BuildRunRequest {
        build: BuildRequest {
            environment: id.to_owned(),
            main_file: test.main_file.clone(),
            files: test.files.clone(),
            ..Default::default()
        },
        run: RunRequest {
            stdin: Some("stdin".into()),
            args: ["foo", "bar", "baz"].into_iter().map(Into::into).collect(),
            files: vec![File {
                name: "test.txt".into(),
                content: "hello world".into(),
            }],
            ..Default::default()
        },
    })) {
        Ok(response) => {
            assert_ok(&response, environment.compiled);
            assert_eq!(
                response.run.stdout.trim(),
                test.expected.as_deref().unwrap_or("OK")
            );
        }
        Err(_) => panic!("request failed"),
    }
}

fn test_example(id: &str, environment: &Environment) {
    let Some(content) = &environment.example else {
        return;
    };

    match dbg!(client().build_and_run(&BuildRunRequest {
        build: BuildRequest {
            environment: id.to_owned(),
            main_file: MainFile {
                name: None,
                content: content.clone(),
            },
            ..Default::default()
        },
        run: RunRequest {
            stdin: Some("Foo42".into()),
            ..Default::default()
        },
    })) {
        Ok(response) => {
            assert_ok(&response, environment.compiled);
            assert_eq!(response.run.stdout.trim(), "Hello, Foo42!");
        }
        Err(_) => panic!("request failed"),
    }
}

fn assert_ok(response: &BuildRunResult, compiled: bool) {
    if compiled {
        let build = response.build.as_ref().unwrap();
        assert_eq!(build.status, 0);
        assert!(build.stderr.is_empty());
    } else {
        assert!(response.build.is_none());
    }
    assert_eq!(response.run.status, 0);
    assert!(response.run.stderr.is_empty());
}
