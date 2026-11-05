{
  description = "Machine translation of the GNU Emacs manuals into Japanese, served at emacs-doc.conao3.com";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    treefmt-nix.url = "github:numtide/treefmt-nix";
    plamo-tr-po.url = "github:conao3/rust-plamo-tr-po";
    plamo-tr-po.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-darwin"
      ];

      imports = [ inputs.treefmt-nix.flakeModule ];

      perSystem =
        { pkgs, inputs', ... }:
        let
          tools = with pkgs; [
            coreutils
            gettext
            git
            gnumake
            gnused
            po4a
            texinfo
            wrangler
            inputs'.plamo-tr-po.packages.default
          ];
        in
        {
          packages.default = pkgs.writeShellApplication {
            name = "emacs-doc";
            runtimeInputs = tools;
            text = ''exec make "$@"'';
            meta.description = "Run the emacs-doc Makefile targets (fetch, pot, translate, site, deploy)";
          };

          devShells.default = pkgs.mkShell {
            packages = tools ++ [ pkgs.shellcheck ];
          };

          treefmt.programs = {
            nixfmt.enable = true;
            shfmt.enable = true;
          };
        };
    };
}
