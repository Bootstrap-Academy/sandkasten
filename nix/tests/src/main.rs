use std::{collections::HashMap, str::FromStr, sync::LazyLock};

use regex::Regex;
use sandkasten_client::{schemas::environments::Environment, BlockingSandkastenClient};

mod api;
mod async_client;
mod attacks;
mod packages;
mod proptests;

type TestFn = Box<dyn Fn() + Send + Sync + 'static>;
type TestCollection = Vec<(String, TestFn)>;

static TEST_COLLECTIONS: LazyLock<Vec<&TestCollection>> = LazyLock::new(|| {
    vec![
        &api::TESTS,
        &async_client::TESTS,
        &attacks::TESTS,
        &packages::TESTS,
        &proptests::TESTS,
    ]
});

fn main() {
    let filter = std::env::args()
        .nth(1)
        .map(|s| s.parse::<TestFilter>())
        .transpose()
        .unwrap();

    for &tests in &*TEST_COLLECTIONS {
        for (name, test_fn) in tests {
            let name = name.strip_prefix("sandkasten_tests::").unwrap();
            if filter.as_ref().is_none_or(|f| f.matches(name)) {
                eprintln!("\x1b[0m\x1b[1m\x1b[32m     Testing\x1b[0m {name}");
                test_fn();
            } else {
                eprintln!("\x1b[0m\x1b[1m\x1b[33m    Skipping\x1b[0m {name}");
            }
        }
    }
}

fn client() -> BlockingSandkastenClient {
    BlockingSandkastenClient::new("http://127.0.0.1:8000".parse().unwrap())
}

#[macro_export]
macro_rules! tests {
    ($($ident:ident),* $(,)?) => {
        pub static TESTS: std::sync::LazyLock<$crate::TestCollection> =
            std::sync::LazyLock::new(|| vec![$((concat!(module_path!(), "::", stringify!($ident)).into(), Box::new($ident))),*]);
        const _NO_DUPLICATES: () = { $( #[allow(dead_code, non_camel_case_types)] struct $ident; )* };
    };
}

static ENVIRONMENTS: LazyLock<HashMap<String, Environment>> =
    LazyLock::new(|| client().list_environments().unwrap());

#[derive(Debug, Clone)]
struct TestFilter {
    regex: Regex,
    mode: FilterMode,
}

#[derive(Debug, Clone, Copy)]
enum FilterMode {
    Include,
    Exclude,
}

impl FromStr for TestFilter {
    type Err = regex::Error;

    fn from_str(s: &str) -> Result<Self, Self::Err> {
        Ok(match s.strip_prefix("!") {
            Some(s) => Self {
                regex: Regex::new(s)?,
                mode: FilterMode::Exclude,
            },
            None => Self {
                regex: Regex::new(s)?,
                mode: FilterMode::Include,
            },
        })
    }
}

impl TestFilter {
    fn matches(&self, test: &str) -> bool {
        let matches_regex = self.regex.is_match(test);
        match self.mode {
            FilterMode::Include => matches_regex,
            FilterMode::Exclude => !matches_regex,
        }
    }
}
