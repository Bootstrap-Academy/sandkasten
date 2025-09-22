{
  config,
  lib,
  pkgs,
  ...
}:

let
  manifestFormat = pkgs.formats.json { };

  scriptModule = name: script: {
    options = {
      script = lib.mkOption {
        type = lib.types.str;
        description = "The script.";
      };

      path = lib.mkOption {
        type = lib.types.listOf lib.types.package;
        description = "List of packages to add to the PATH.";
        default = [ ];
      };

      environment = lib.mkOption {
        type = lib.types.attrsOf lib.types.str;
        description = "Environment variables.";
        default = { };
      };

      finalPackage = lib.mkOption {
        type = lib.types.package;
        readOnly = true;
        internal = true;
      };
    };

    config = {
      environment.PATH = lib.makeBinPath script.config.path;
      finalPackage = pkgs.writeShellScript "sandkasten-${config.id}-${config.version}-${name}" ''
        ${lib.concatMapAttrsStringSep "\n" (
          name: value: "export ${name}=${lib.escapeShellArg value}"
        ) script.config.environment}
        ${script.config.script}
      '';
    };
  };

  fileModule = {
    options = {
      name = lib.mkOption {
        type = lib.types.str;
        description = "File name.";
        example = "test.rs";
      };

      content = lib.mkOption {
        type = lib.types.str;
        description = "File content.";
        example = ''
          fn main() {
            println!("OK");
          }
        '';
      };
    };
  };

  closureOf =
    paths: "${pkgs.closureInfo { rootPaths = lib.filter (p: p != null) paths; }}/store-paths";

  compile_script = if config.compile != null then config.compile.finalPackage else null;
  run_script = config.run.finalPackage;
in

{
  _class = "sandkastenPackage";

  options = {
    id = lib.mkOption {
      type = lib.types.str;
      description = "Unique identifier of the environment.";
      example = "rust";
    };

    name = lib.mkOption {
      type = lib.types.str;
      description = "Name of the environment.";
      example = "Rust";
    };

    version = lib.mkOption {
      type = lib.types.str;
      description = "Version of the environment.";
    };

    sandkasten_version = lib.mkOption {
      type = lib.types.str;
      readOnly = true;
      internal = true;
    };

    meta = lib.mkOption {
      type = lib.types.attrsOf manifestFormat.type;
      description = "Additional metadata.";
      default = { };
    };

    manifest = lib.mkOption {
      type = manifestFormat.type;
      readOnly = true;
      internal = true;
    };

    finalPackage = lib.mkOption {
      type = lib.types.package;
      readOnly = true;
      internal = true;
    };

    default_main_file_name = lib.mkOption {
      type = lib.types.str;
      description = "Default file name for the main entrypoint into the program.";
      example = "code.rs";
    };

    compile = lib.mkOption {
      type = lib.types.nullOr (lib.types.submodule (scriptModule "compile"));
      description = "Compile script.";
      default = null;
    };

    run = lib.mkOption {
      type = lib.types.submodule (scriptModule "run");
      description = "Run script.";
    };

    example = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      description = "Program example.";
      example = ''
        fn main() {
            println!("Hello, world!");
        }
      '';
      default = null;
    };

    test = lib.mkOption {
      type = lib.types.submodule {
        options = {
          main_file = lib.mkOption {
            type = lib.types.submodule fileModule;
            description = "Main source file.";
          };

          files = lib.mkOption {
            type = lib.types.listOf (lib.types.submodule fileModule);
            description = "List of additional source files.";
            default = [ ];
          };

          expected = lib.mkOption {
            type = lib.types.str;
            description = "Expected output of stdout after removing leading and trailing whitespace.";
            default = "OK";
          };
        };

        config.main_file.name = lib.mkDefault config.default_main_file_name;
      };
      description = "Integration test to verify basic functionality of this environment.";
    };
  };

  config = {
    manifest =
      removeAttrs config [
        "_module"
        "manifest"
        "finalPackage"
        "compile"
        "run"
      ]
      // {
        inherit compile_script run_script;
        closure = closureOf [
          compile_script
          run_script
        ];
      };

    finalPackage =
      (manifestFormat.generate "sandkasten-${config.id}-${config.version}.json" config.manifest)
      .overrideAttrs
        { passthru = { inherit config; }; };
  };
}
