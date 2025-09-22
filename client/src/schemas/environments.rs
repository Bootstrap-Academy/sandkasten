//! Schemas for environments endpoints.

use std::collections::HashMap;

#[cfg(feature = "poem-openapi")]
use poem_openapi::{types::Example, NewType, Object};
use serde::{Deserialize, Serialize};
use serde_json::Value;

use super::programs::ResourceUsage;
use crate::schemas::programs::{File, MainFile};

/// A package that can build and run programs.
#[derive(Debug, Clone, Serialize, Deserialize)]
#[cfg_attr(feature = "poem-openapi", derive(Object))]
pub struct Environment {
    /// The display name of the environment (e.g. `Rust` or `C++`).
    pub name: String,
    /// The version of the environment.
    pub version: String,
    /// The default name of the main file that is used if no filename is
    /// specified.
    pub default_main_file_name: String,
    /// An example program for this environment.
    pub example: Option<String>,
    /// A test program to verify basic functionality of this environment.
    pub test: Option<Test>,
    /// Whether the environment has a `compile_script`.
    pub compiled: bool,
    /// Additional metadata specific to the environment.
    pub meta: HashMap<String, Value>,
}

/// A test program to verify basic functionality of an environment.
#[derive(Debug, Clone, Serialize, Deserialize)]
#[cfg_attr(feature = "poem-openapi", derive(Object))]
pub struct Test {
    /// The main source file that represents the entrypoint to the program.
    pub main_file: MainFile,
    /// A list of additional source files.
    pub files: Vec<File>,
    /// The expected output.
    pub expected: String,
}

/// A map of environments where the key represents the id of the environment.
#[derive(Debug, Clone)]
#[cfg_attr(feature = "poem-openapi", derive(NewType))]
#[cfg_attr(
    feature = "poem-openapi",
    oai(
        from_parameter = false,
        from_multipart = false,
        to_header = false,
        example = true
    )
)]
pub struct ListEnvironmentsResponse(pub HashMap<String, Environment>);

/// The base resource usage of an environment.
#[derive(Debug, Clone, Copy, Serialize, Deserialize)]
#[cfg_attr(feature = "poem-openapi", derive(Object))]
pub struct BaseResourceUsage {
    /// The base resource usage of the build step.
    pub build: Option<ResourceUsage>,
    /// The base resource usage of the run step.
    pub run: RunResourceUsage,
}

/// The base resource usage of the run step.
#[derive(Debug, Clone, Copy, Serialize, Deserialize)]
#[cfg_attr(feature = "poem-openapi", derive(Object))]
pub struct RunResourceUsage {
    /// The number of **milliseconds** the process ran.
    pub time: BenchmarkResult,
    /// The amount of memory the process used (in **KB**)
    pub memory: BenchmarkResult,
}

/// Accumulated benchmark results.
#[derive(Debug, Clone, Copy, Serialize, Deserialize)]
#[cfg_attr(feature = "poem-openapi", derive(Object))]
pub struct BenchmarkResult {
    /// The minimum of the measured values.
    pub min: u64,
    /// The average of the measured values.
    pub avg: u64,
    /// The maximum of the measured values.
    pub max: u64,
}

/// The error responses that may be returned when calculating the base resource
/// usage.
#[derive(Debug, Clone, Deserialize)]
#[serde(tag = "error", content = "details", rename_all = "snake_case")]
pub enum GetBaseResourceUsageError {
    /// Environment does not exist.
    EnvironmentNotFound,
}

#[cfg(feature = "poem-openapi")]
impl Example for ListEnvironmentsResponse {
    fn example() -> Self {
        use serde_json::json;

        Self(HashMap::from([
            (
                "rust".into(),
                Environment {
                    name: "Rust".into(),
                    version: "1.64.0".into(),
                    default_main_file_name: "code.rs".into(),
                    example: None,
                    test: None,
                    compiled: true,
                    meta: [("homepage".into(), json!("https://www.rust-lang.org/"))].into(),
                },
            ),
            (
                "python".into(),
                Environment {
                    name: "Python".into(),
                    version: "3.11.1".into(),
                    default_main_file_name: "code.py".into(),
                    example: Some("name = input()\nprint(f\"Hello, {name}!\")".into()),
                    test: None,
                    compiled: false,
                    meta: [("packages".into(), json!(["numpy", "pandas"]))].into(),
                },
            ),
        ]))
    }
}

impl FromIterator<u64> for BenchmarkResult {
    fn from_iter<T: IntoIterator<Item = u64>>(iter: T) -> Self {
        let mut iter = iter.into_iter();
        let first = iter.next().unwrap();
        let mut min = first;
        let mut max = first;
        let mut sum = first;
        let mut cnt = 1;
        for x in iter {
            min = min.min(x);
            max = max.max(x);
            sum += x;
            cnt += 1;
        }
        BenchmarkResult {
            min,
            max,
            avg: sum / cnt,
        }
    }
}
