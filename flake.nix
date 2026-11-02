# The official Nix flake for super.engineering on Linux. It packages the signed release tarballs
# that nix/sources.json pins (scripts/update-nix-pin.sh verifies each manifest before pinning).
{
  description = "super.engineering: a native workspace for parallel coding agents";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

  outputs =
    { self, nixpkgs }:
    let
      lib = nixpkgs.lib;
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      sources = lib.importJSON ./nix/sources.json;
      channels = builtins.filter (channel: sources.${channel} != null) [
        "stable"
        "nightly"
      ];
      pkgsFor =
        system:
        import nixpkgs {
          inherit system;
          # The app is proprietary; allow exactly this package.
          config.allowUnfreePredicate = pkg: lib.getName pkg == "super-engineering";
        };
      forAllSystems = f: lib.genAttrs systems (system: f system (pkgsFor system));
    in
    {
      # One package per pinned channel; default is stable once it is pinned, else nightly.
      packages = forAllSystems (
        system: pkgs:
        let
          byChannel = lib.genAttrs channels (
            channel:
            pkgs.callPackage ./nix/package.nix {
              inherit channel;
              release = sources.${channel};
            }
          );
        in
        byChannel // { default = byChannel.${builtins.head channels}; }
      );

      apps = forAllSystems (
        system: pkgs:
        let
          package = self.packages.${system}.default;
        in
        {
          default = {
            type = "app";
            program = "${package}/bin/super-engineering";
            meta.description = "Launch super.engineering";
          };
          sc = {
            type = "app";
            program = "${package}/bin/sc";
            meta.description = "The super.engineering CLI";
          };
        }
      );

      # The package installs and runs, its desktop entry points into the store, and the wrapper
      # sets no library path for the terminals and agents the app starts.
      checks = forAllSystems (
        system: pkgs:
        let
          package = self.packages.${system}.default;
        in
        {
          package = pkgs.runCommand "super-engineering-check" { } ''
            ${package}/bin/sc --version | grep -q '^super.engineering-cli '
            grep -q "^Exec=${package}/bin/super-engineering$" ${package}/share/applications/engineering.super.app.desktop
            test -x ${package}/bin/sc-linux-x86_64 && test -x ${package}/bin/sc-linux-aarch64
            if grep -q LD_LIBRARY_PATH ${package}/bin/super-engineering; then
              echo "the wrapper sets LD_LIBRARY_PATH" >&2
              exit 1
            fi
            touch $out
          '';
        }
      );
    };
}
