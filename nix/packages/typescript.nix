{pkgs, ...}: let
  node_modules = let
    nodePackage = name: src:
      pkgs.stdenv.mkDerivation {
        inherit name;
        src = pkgs.fetchurl src;
        installPhase = "cp -r . $out";
      };
  in
    pkgs.linkFarm "node_modules" (builtins.mapAttrs nodePackage {
      "@types/node" = {
        url = "https://registry.npmjs.org/@types/node/-/node-20.10.0.tgz";
        hash = "sha256-tvBAR7uPjL6OcZjNzC3Pl3atYCWcR8mpeKlx6BitPvI=";
      };
      "undici-types" = {
        url = "https://registry.npmjs.org/undici-types/-/undici-types-6.20.0.tgz";
        hash = "sha256-coyp/P9nY3Lk3NZIteJvu9sonsK89nXnYBzCE0pejW4=";
      };
    });
in {
  name = "TypeScript";
  version = pkgs.typescript.version;
  meta = {
    compiler = {
      name = "tsc";
      version = pkgs.typescript.version;
      inherit (pkgs.typescript.meta) description homepage;
    };
    runtime = {
      name = "NodeJS";
      version = pkgs.nodejs.version;
      inherit (pkgs.nodejs.meta) description homepage;
    };
  };
  default_main_file_name = "code.ts";
  compile_script = ''
    ${pkgs.coreutils}/bin/cp $(${pkgs.coreutils}/bin/ls -A) /tmp
    cd /tmp
    ${pkgs.coreutils}/bin/cp -rL ${node_modules} node_modules
    ${pkgs.typescript}/bin/tsc -m node16 --outDir /program/ "$@"
  '';
  run_script = ''
    main=/program/$(${pkgs.coreutils}/bin/basename "$1" .ts).js
    shift
    ${pkgs.nodejs}/bin/node "$main" "$@"
  '';
  example = ''
    import * as fs from "fs";

    let name = fs.readFileSync(0).toString();
    console.log("Hello, " + name + "!");
  '';
  test.main_file.content = ''
    import { bar } from "./foo";
    import * as fs from "fs";

    if (fs.readFileSync(0).toString() != "stdin") process.exit(1);

    if (process.argv.length-2 != 3) process.exit(2);
    if (process.argv[2] != "foo") process.exit(3);
    if (process.argv[3] != "bar") process.exit(4);
    if (process.argv[4] != "baz") process.exit(5);

    if (fs.readFileSync("test.txt").toString() != "hello world") process.exit(6);

    bar()
  '';
  test.files = [
    {
      name = "foo.ts";
      content = ''
        export function bar() {
          console.log("OK")
        }
      '';
    }
  ];
}
