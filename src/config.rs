use std::{env, path::PathBuf};

use anyhow::Context;
use config::{File, FileFormat};
use sandkasten_client::schemas::programs::Limits;
use serde::Deserialize;
use tracing::info;

pub fn load() -> Result<Config, anyhow::Error> {
    let path = env::var("CONFIG_PATH").context("Environment variable CONFIG_PATH not set")?;
    info!("Loading config from {path}");

    let conf = std::iter::once(anyhow::Ok(File::from_str(
        include_str!("../config.toml"),
        FileFormat::Toml,
    )))
    .chain(path.rsplit(':').map(|path| {
        let content = std::fs::read_to_string(path)?;
        Ok(File::from_str(&content, FileFormat::Toml))
    }))
    .try_fold(config::Config::builder(), |builder, source| {
        anyhow::Ok(builder.add_source(source?))
    })?
    .build()
    .context("Failed to load config")?
    .try_deserialize::<Config>()
    .context("Failed to parse config")?;

    Ok(Config {
        base_resource_usage: BaseResourceUsageConfig {
            permits: conf
                .base_resource_usage
                .permits
                .min(conf.max_concurrent_jobs as _),
            ..conf.base_resource_usage
        },
        nsjail_path: conf.nsjail_path.canonicalize().with_context(|| {
            format!(
                "Failed to resolve `nsjail_path` {}",
                conf.nsjail_path.display()
            )
        })?,
        time_path: conf.time_path.canonicalize().with_context(|| {
            format!("Failed to resolve `time_path` {}", conf.time_path.display())
        })?,
        ..conf
    })
}

#[derive(Debug, Deserialize)]
#[serde(deny_unknown_fields)]
pub struct Config {
    /// The host to listen on.
    pub host: String,
    /// The port to listen on.
    pub port: u16,
    /// The path prefix added by a reverse proxy. Set to `"/"` if you don't have
    /// a reverse proxy.
    pub server: String,

    /// Whether to expose Prometheus metrics on `/metrics`.
    pub enable_metrics: bool,

    /// The directory where programs are stored.
    pub programs_dir: PathBuf,
    /// The directory where files for jobs are stored.
    pub jobs_dir: PathBuf,

    /// The time to live for programs in seconds.
    pub program_ttl: u64,
    /// The number of seconds to wait between deleting old programs.
    pub prune_programs_interval: u64,

    /// The maximum number of jobs that can run at the same time.
    pub max_concurrent_jobs: usize,

    /// The maximum allowed limits for compile steps.
    pub compile_limits: Limits,
    /// The maximum allowed limits for run steps.
    pub run_limits: Limits,

    /// Config for measuring the base resource usage of an environment.
    pub base_resource_usage: BaseResourceUsageConfig,

    /// Whether to use cgroup to set resource limits where possible. It is
    /// strongly recommended to set this to true in production environments!
    pub use_cgroup: bool,
    /// The path to the nsjail binary. This binary must have the setuid bit set
    /// and it must be owned by root OR sandkasten itself must be run as root.
    pub nsjail_path: PathBuf,
    /// The path to the time binary.
    pub time_path: PathBuf,

    /// A list of paths to load environments from.
    pub environments_path: Vec<PathBuf>,
}

#[derive(Debug, Deserialize)]
#[serde(deny_unknown_fields)]
pub struct BaseResourceUsageConfig {
    /// The number of times the program is run.
    pub runs: usize,
    /// The number of permits to acquire from the internal request semaphore
    /// If set to the value of `max_concurrent_jobs`, no other jobs can run at
    /// the same time.
    #[serde(default = "default_base_resource_usage_permits")]
    pub permits: u32,
    /// The time to live for base resource usage cache entries in seconds.
    pub cache_ttl: u64,
}

fn default_base_resource_usage_permits() -> u32 {
    u32::MAX
}
