{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    sandkasten.url = "git+https://git.defelo.de/Defelo/sandkasten?ref=latest";
  };

  outputs =
    { nixpkgs, sandkasten, ... }:
    let
      system = "x86_64-linux";
    in
    {
      nixosConfigurations.sandkasten = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit sandkasten; };
        modules = [
          ./sandkasten.nix
          ./configuration.nix
          ./hardware-configuration.nix
        ];
      };
    };
}
