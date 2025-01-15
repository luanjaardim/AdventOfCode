{
  description = "Dev Shell for Rust using Flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs }:
  let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in
  {

    devShells.${system}.default = pkgs.mkShell {

      buildInputs = with pkgs; [ rustc cargo rust-analyzer rustfmt clippy clang gdb ];

      shellHook = ''
        export PATH="$PATH:$HOME/.cargo/bin"
        export SHELL="$(which nu)"
        exec $SHELL
      '';

    };

  };
}
