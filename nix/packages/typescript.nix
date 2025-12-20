{ lib, pkgs, ... }:

let
  nodePackage =
    name: src:
    pkgs.stdenvNoCC.mkDerivation {
      inherit name;
      src = pkgs.fetchurl src;
      installPhase = "cp -r . $out";
    };

  node_modules = pkgs.linkFarm "node_modules" (
    lib.mapAttrs nodePackage {
      "@types/node" = {
        url = "https://registry.npmjs.org/@types/node/-/node-25.0.3.tgz";
        hash = "sha256-b06okzh+9q0rui9qOx5sHHtIWKe7SdfsLKqrUoMoqgQ=";
      };
      "undici-types" = {
        url = "https://registry.npmjs.org/undici-types/-/undici-types-7.16.0.tgz";
        hash = "sha256-U7Xi+hKkEYpIOOgLHMbh2M0w1vflvqaWQOU4b26z+K8=";
      };
    }
  );
in

{
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

  compile.path = lib.attrValues { inherit (pkgs) coreutils typescript; };
  compile.script = ''
    cp $(ls -A) /tmp
    cd /tmp
    cp -rL ${node_modules} node_modules
    tsc -m node16 --outDir /program/ "$@"
  '';

  run.path = lib.attrValues { inherit (pkgs) coreutils nodejs; };
  run.script = ''
    main=/program/$(basename "$1" .ts).js
    shift
    node "$main" "$@"
  '';

  example = # typescript
    ''
      import * as fs from "fs";

      let name = fs.readFileSync(0).toString();
      console.log("Hello, " + name + "!");
    '';

  test.main_file.content = # typescript
    ''
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
      content = # typescript
        ''
          export function bar() {
            console.log("OK")
          }
        '';
    }
  ];
}
