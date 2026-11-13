{
  description = "PROTOTYPE: Dock, Finder and desktop settings via nix-darwin";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    { nix-darwin, ... }:
    {
      darwinConfigurations.default = nix-darwin.lib.darwinSystem {
        modules = [ ./configuration.nix ];
      };
    };
}
