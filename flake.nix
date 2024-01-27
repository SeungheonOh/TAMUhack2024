{
  description = "Foo Bar Baz";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";

    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs = inputs@{self, flake-parts, nixpkgs, ...}:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-darwin" "x86_64-darwin" "aarch64-linux" ];
      perSystem = {system, lib, ...}:
        let
          pkgs = import nixpkgs {
            inherit system;
          };

          version =
            builtins.substring 0 8
              (self.lastModifiedDate or self.lastModified or "19700101");

          hack = pkgs.buildGoModule {
            pname = "hack";
            inherit version;
            src = ./.;
            vendorHash = "sha256-j3HZdDD3N4W/ETr9AeEoBZBZ7pGuYSxF/RbuZt6UcxE=";
          };
        in
          {
            packages = {
              inherit hack;
            };

            devShells.default = pkgs.mkShell {
              buildInputs = with pkgs; [go gopls gotools go-tools];
            };
          };
    };
}
