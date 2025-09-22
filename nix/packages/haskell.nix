{ lib, pkgs, ... }:

{
  name = "Haskell";
  version = pkgs.ghc.version;
  meta = {
    compiler = {
      name = "GHC";
      version = pkgs.ghc.version;
      inherit (pkgs.ghc.meta) description homepage;
    };
  };
  default_main_file_name = "code.hs";

  compile.path = lib.attrValues { inherit (pkgs) coreutils gcc ghc; };
  compile.script = ''
    cp $(ls -A) /tmp
    cd /tmp
    ghc -O -o /program/binary --make "$1"
  '';

  run.script = ''
    shift
    /program/binary "$@"
  '';

  example = # haskell
    ''
      main :: IO ()
      main = do
        name <- getLine
        putStrLn $ "Hello, " ++ name ++ "!"
    '';

  test.main_file.content = # haskell
    ''
      import System.Environment
      import System.Exit
      import Foo

      main :: IO ()
      main = do
        inputStr <- getLine
        if inputStr /= "stdin"
          then exitWith (ExitFailure 1)
          else do
            args <- getArgs
            if length args /= 3
              then exitWith (ExitFailure 2)
              else do
                let arg1 = args !! 0
                    arg2 = args !! 1
                    arg3 = args !! 2
                if arg1 /= "foo"
                  then exitWith (ExitFailure 3)
                  else if arg2 /= "bar"
                    then exitWith (ExitFailure 4)
                    else do
                      fileContent <- readFile "test.txt"
                      if fileContent /= "hello world"
                        then exitWith (ExitFailure 6)
                        else do
                          putStrLn bar
    '';
  test.files = [
    {
      name = "Foo.hs";
      content = # haskell
        ''
          module Foo where
          bar = "OK"
        '';
    }
  ];
}
