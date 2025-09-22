{ lib, pkgs, ... }:

{
  name = "Kotlin";
  version = pkgs.kotlin.version;
  meta = { inherit (pkgs.kotlin.meta) description longDescription homepage; };
  default_main_file_name = "code.kt";

  compile.path = lib.attrValues { inherit (pkgs) coreutils kotlin; };
  compile.script = ''
    kotlinc -include-runtime -d /program/program.jar "$@"
  '';

  run.path = lib.attrValues { inherit (pkgs) coreutils kotlin; };
  run.script = ''
    shift
    kotlin /program/program.jar "$@"
  '';

  example = # kotlin
    ''
      fun main() {
        val name = readln()
        println("Hello, " + name + "!")
      }
    '';
  test.main_file.content = # kotlin
    ''
      import foo.bar;

      fun main() {
          bar()
      }
    '';
  test.files = [
    {
      name = "foo.kt";
      content = # kotlin
        ''
          package foo;

          fun bar() {
            println("OK")
          }
        '';
    }
  ];
}
