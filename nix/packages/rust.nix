{ lib, pkgs, ... }:

let
  edition = "2021";
in

{
  name = "Rust";
  version = pkgs.rustc.version;
  meta = {
    inherit (pkgs.rustc.meta) description homepage;
    inherit edition;
  };
  default_main_file_name = "code.rs";

  compile.path = lib.attrValues { inherit (pkgs) rustc gcc; };
  compile.script = ''
    rustc --edition=${edition} -O -o /program/binary "$1"
  '';

  run.script = ''
    shift
    /program/binary "$@"
  '';

  example = # rust
    ''
      fn main() {
        let mut name = String::new();
        std::io::stdin().read_line(&mut name).unwrap();
        println!("Hello, {name}!");
      }
    '';

  test.main_file.content = # rust
    ''
      mod foo;
      fn main() {
        let mut s = String::new();
        std::io::stdin().read_line(&mut s).unwrap();
        assert_eq!(s, "stdin");

        let mut args = std::env::args();
        args.next().unwrap();
        for x in ["foo", "bar", "baz"].into_iter().map(|x: &str| x) {
          assert_eq!(args.next().unwrap(), x);
        }

        let s = std::fs::read_to_string("test.txt").unwrap();
        assert_eq!(s, "hello world");

        foo::bar();
      }
    '';
  test.files = [
    {
      name = "foo.rs";
      content = # rust
        ''
          pub fn bar() {
            println!("OK");
          }
        '';
    }
  ];
}
