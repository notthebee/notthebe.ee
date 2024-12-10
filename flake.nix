{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/release-24.11";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } (
      { self, lib, ... }:
      {
        systems = [
          "x86_64-linux"
          "aarch64-darwin"
        ];
        perSystem =
          { pkgs, ... }:
          {
            packages = {
              default = pkgs.mkShell {
                packages = [
                  pkgs.bashInteractive
                  pkgs.zola
                  pkgs.git
                ];
              };
            };
          };
      }
    );
}
