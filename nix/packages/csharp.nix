{
  lib,
  pkgs,
  pkgs-csharp,
  ...
}:

let
  inherit (pkgs-csharp) dotnet-sdk;

  env = {
    HOME = "/tmp/.dotnet";
    DOTNET_CLI_TELEMETRY_OPTOUT = "1";
  };
in

{
  name = "C#";
  version = dotnet-sdk.version;
  meta = { inherit (dotnet-sdk.meta) homepage; };
  default_main_file_name = "code.cs";

  compile.path = lib.attrValues {
    inherit (pkgs) coreutils;
    inherit dotnet-sdk;
  };
  compile.environment = env;
  compile.script = ''
    cp $(ls -A) /tmp
    cd /tmp
    dotnet new console -o . --no-restore
    rm Program.cs
    dotnet restore
    dotnet build --no-restore -o /program
  '';

  run.path = lib.attrValues { inherit dotnet-sdk; };
  run.environment = env;
  run.script = ''
    shift
    dotnet /program/*.dll "$@"
  '';

  example = # csharp
    ''
      string name = Console.In.ReadLine();
      Console.WriteLine("Hello, " + name + "!");
    '';

  test.main_file.content = # csharp
    ''
      using System;

      public class Test {
          public static int Main(string[] args) {
              string s = Console.In.ReadLine();
              if (s != "stdin") return 1;

              if (args.Length != 3) return 2;
              if (args[0] != "foo") return 3;
              if (args[1] != "bar") return 4;
              if (args[2] != "baz") return 5;

              s = File.ReadAllText("test.txt");
              if (s != "hello world") return 6;

              Foo.bar();
              return 0;
          }
      }
    '';
  test.files = [
    {
      name = "foo.cs";
      content = # csharp
        ''
          using System;

          public class Foo {
            public static void bar() {
              Console.WriteLine("OK");
            }
          }
        '';
    }
  ];
}
