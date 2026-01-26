{
  lib,
  pkgs,
  self,
  module,
}:

let
  webUrl = "https://radicle.defelo.de/nodes/radicle.defelo.de/rad:zKBbWZxz73j7BZMbutM7TMMT4v5K/tree";

  eval = lib.evalModules {
    modules = [
      {
        config._module.check = false;
        config._module.args = { inherit pkgs; };
        options._module.args = lib.mkOption { internal = true; };
      }
      module
    ];
  };

  removeTrailingNewlineInLiteralExpression =
    opt:
    if opt.default._type or null == "literalExpression" then
      opt // { default = lib.literalExpression (lib.removeSuffix "\n" opt.default.text); }
    else
      opt;

  docs =
    (pkgs.nixosOptionsDoc {
      inherit (eval) options;
      transformOptions = lib.flip lib.pipe [ removeTrailingNewlineInLiteralExpression ];
    }).optionsCommonMark;
in

pkgs.runCommand "docs" { } ''
  ${lib.getExe pkgs.gnused} -E 's|\[${self}/(.*)\]\(.*\)|[\1](${webUrl}/\1)|' ${docs} > $out
''
