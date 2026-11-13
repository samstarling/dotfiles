{
  description = "PROTOTYPE: Dock, Finder and desktop settings via nix-darwin";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    { nix-darwin, ... }:
    let
      # One configuration per macOS user name, picked with `--flake .#<user>`.
      forUser =
        user:
        nix-darwin.lib.darwinSystem {
          modules = [
            ./configuration.nix
            { system.primaryUser = user; }
          ];
        };
    in
    {
      darwinConfigurations = {
        admin = forUser "admin";
        sam = forUser "sam";
      };
    };
}
