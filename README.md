# Sandkasten
Run untrusted code in an isolated environment

## What is this?
Sandkasten is a code execution engine for running arbitrary untrusted/harmful code in a sandbox,
isolating it from both the host system and other Sandkasten jobs. A simple REST API allows uploading
and executing arbitrary programs, while also enabling the user to specify resource limits and
providing feedback on the actual resources used. This project was partly inspired by
[Piston](https://github.com/engineer-man/piston) and aims to solve some problems with it.

## How does it work?
Sandkasten uses [nsjail](https://github.com/google/nsjail) to run programs in restricted
environments and to enforce the specified resource limits. Additionally
[GNU Time](https://www.gnu.org/software/time/) is used for reporting the resources used by the
program. Programs are always run in a chroot environment using nsjail, which contains only the
following directories:

- `/program` (rw in compile steps, ro in run steps) contains the compiled program
- `/box` (ro) current working directory which contains the specified files for compile/run steps
- `/tmp` (rw, tmpfs)
- the paths in `/nix/store` that are needed by the selected environment (ro mount from host)
- some files in `/dev` and `/etc` which are needed for some packages to work properly

Programs are uniquely identified using the hash value of their source files and selected
environments. If a program has been uploaded and compiled before and is then uploaded again, the
same program id is used and the existing compilation results can be used without having to recompile
the program.

## Features
- [x] Compile and execute arbitrary programs.
- [x] Cache compilation results to avoid having to recompile the same programs for every time they
      are run.
- [x] Set resource limits for both compile and run steps.
- [x] Report resource usage for both compile and run steps.
- [x] Packages are defined using [Nix](https://nixos.org/).
- [x] Programs are deleted automatically if they are not executed anymore.
- [x] Specify stdin, command line arguments and files in the working directory for run steps.
- [x] Specify environment variables for both compile and run steps.
- [x] Client library for Rust ([crate](https://crates.io/crates/sandkasten-client),
      [documentation](https://docs.rs/sandkasten-client))
- [x] Optional [Prometheus](https://prometheus.io/docs/introduction/overview/) metrics on `/metrics`

### Planned/Ideas
- [ ] Communicate with running programs via websockets.
- [ ] Spawn multiple processes that can communicate with each other.
- [ ] JWTs for individual limits (+rate limits).
- [ ] Add more packages.

## API Documentation
On a running Sandkasten instance, the API documentation is available on `<instance>/docs` and
`<instance>/redoc`. There is also an OpenAPI specification available on `<instance>/openapi.json`.

## Setup Instructions (NixOS)

1. Add this repository as an input to your `flake.nix`:
    ```nix
    {
      inputs.sandkasten.url = "git+https://radicle.defelo.de/zKBbWZxz73j7BZMbutM7TMMT4v5K.git";
    }
    ```
2. Add the module to your NixOS configuration:
    ```nix
    {
      imports = [ sandkasten.nixosModules.default ];
    }
    ```

## NixOS Module Options
[search.defelo.de](https://search.defelo.de/?scope=sandkasten)

## Development

### Setup instructions

#### Required software
The following components are needed for a working development environment:

- [Rust](https://www.rust-lang.org/) (stable) toolchain
- [Nix](https://nixos.org/) with [flakes](https://nixos.wiki/wiki/Flakes) enabled
- [direnv](https://github.com/direnv/direnv) (optional, but recommended)

#### Enter the development shell
If you have direnv installed, you can just use
`direnv allow` to setup your shell for development. Otherwise you can also use `nix develop`
to enter a development shell. This will add some tools to your `PATH` and set a few environment
variables that are needed by Sandkasten.

#### Setup nsjail
The first time you enter the development shell, you should run the `setup-nsjail` command, which
will copy the `nsjail` binary into your current working directoy, `chown` it to `root` and set the
`setuid` bit to allow Sandkasten to run this binary as root without having to run Sandkasten itself
as root (but of course you could also do that).

#### Install Sandkasten packages
Before starting Sandkasten, you should build the sandkasten packages with the environments that
you want to be available on your instance. A full list of installable packages is available at
`nix/packages`. To install packages, you can use one of the following commands:

```bash
# to install all packages
nix build --out-link pkgs .#sandkastenPackages.all
# to install only selected packages
nix build --out-link pkgs .#sandkastenPackages.none.withPython.withRust
```

#### Start the application
In the development shell you can just use `cargo run` to start Sandkasten.

### Unit tests
To run the unit tests, you can just use `cargo test`.

### Integration tests
The integration tests are implemented as
[NixOS VM tests](https://nixos.org/manual/nixos/stable/#sec-nixos-tests). To run all tests, use the
command `nix build .#tests`. You can also login to the VM by starting the test driver in interactive
mode using `nix run .#tests.driverInteractive`, which will open a Python REPL, and then running
`machine.start()` to start the VM. After the VM has booted, you can login via SSH using
`ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -p2222 root@localhost`. You can
also access the Sandkasten API on port 8000 on your host.

### Packages
All packages are defined as Nix modules in `nix/packages`. Each package has a unique id, a
human-readable name, a version, optionally a script to compile a program, a script to run a program
and a test program that is executed as part of the integration tests to ensure that the package is
working. For a list of all options, see [search.defelo.de](https://search.defelo.de/?scope=sandkasten-package).

#### Compile scripts
The compile script of a package is executed whenever a new program has been uploaded. When this
script is run, the current working directory (`/box`) contains all the source files and the command
line arguments contain the names of the source files in the same order as they were specified by
the client (starting with `main_file` which represents the entrypoint into the program). The purpose
of the compile script is to compile the provided program and store the result (plus any files that
may be needed to run the program) in `/program`.

If a package does not have a compile script, the source files are instead copied directly into the
program directory.

#### Run scripts
The run script of a package is executed whenever a program is executed. When this script is run, the
current working directory (`/box`) contains the files that have been specified in the run step (if
any) and `/program` contains the files that have been produced by the corresponding compile script
previously (or the source files if the packages does not have a compile script). The first command
line argument is always the name of the `main_file` (which represents the entrypoint into the
program). In most cases, this is only relevant for interpreted languages (like Python) and can be
ignored for most compiled languages. All other command line arguments are the ones specified by the
client and should be forwarded to the actual program.

#### Test program
Every package should provide a test program that checks the following:

- Multiple source files are working (e.g. `first_file.py` can import `second_file.py`)
- Reading from stdin is working. The program should assert that the string `stdin` is read from
  stdin.
- Command line arguments are working. The program should assert that the only three command line
  arguments are `foo`, `bar` and `baz`.
- File system is working. The program should assert that the file `test.txt` in the current working
  directory contains the string `hello world`.

If any of these checks fails, the program should exit with a non-zero exit code. Otherwise, if all
checks passed, it should exit with exit code zero and print `OK` to stdout.
