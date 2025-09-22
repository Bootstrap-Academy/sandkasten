{
  inputs,
  lib,
  linkFarm,
  sandkastenVersion,
  system,
}:

let
  nixpkgsInstances = lib.pipe inputs [
    (lib.filterAttrs (k: _: lib.hasPrefix "nixpkgs-" k))
    (lib.mapAttrs' (k: v: lib.nameValuePair (lib.removePrefix "nix" k) v.legacyPackages.${system}))
  ];

  evalModules =
    id: modules:
    lib.evalModules {
      class = "sandkastenPackage";
      specialArgs.modulesPath = ./.;
      modules = [
        ./module.nix
        {
          _module.args = nixpkgsInstances // {
            pkgs = nixpkgsInstances.pkgs-stable;
          };
          inherit id;
          sandkasten_version = sandkastenVersion;
        }
      ]
      ++ modules;
    };

  ignoredFiles = [
    "default.nix"
    "module.nix"
    "options.md"
  ];

  packageDrvs = lib.pipe ./. [
    builtins.readDir
    lib.attrNames
    (lib.filter (name: !lib.elem name ignoredFiles))
    (map (name: evalModules (lib.removeSuffix ".nix" name) [ ./${name} ]))
    (map (eval: lib.nameValuePair eval.config.id eval.config.finalPackage))
    lib.listToAttrs
  ];

  selectNone = lib.const [ ];
  selectAll = lib.attrValues;
  packages =
    selector:
    let
      entries = lib.listToAttrs (map (x: lib.nameValuePair x.config.id x) (selector packageDrvs));
      passthru = {
        inherit entries;
        selected = packages;
        none = packages selectNone;
        all = packages selectAll;
      }
      // lib.mapAttrs' (
        name: drv: lib.nameValuePair (lib.toCamelCase "with ${name}") (packages (p: selector p ++ [ drv ]))
      ) packageDrvs;
    in
    lib.pipe entries [
      (lib.mapAttrs' (id: drv: lib.nameValuePair "${id}.json" drv))
      (linkFarm "sandkasten-packages")
      (drv: drv.overrideAttrs { inherit passthru; })
    ];
in

packages selectAll
