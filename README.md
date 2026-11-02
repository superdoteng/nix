<p align="center">
  <a href="https://super.engineering">
    <picture>
      <source media="(prefers-color-scheme: dark)" srcset="assets/app-icon-dark.png">
      <img src="assets/app-icon.png" alt="super.engineering" width="88" height="88">
    </picture>
  </a>
</p>

<h1 align="center">super.engineering for Nix</h1>

<p align="center">Your workspace for coding agents. At home on NixOS.</p>

<p align="center">
  <a href="https://super.engineering"><img alt="Linux x86_64 and ARM64" src="https://img.shields.io/badge/Linux-x86__64%20%7C%20ARM64-2ea44f?style=flat&labelColor=313131"></a>
  <a href="https://github.com/sponsors/superdoteng"><img alt="Sponsor" src="https://img.shields.io/badge/-ea4aaa?style=flat&logo=githubsponsors&logoColor=white"></a>
</p>

Run [super.engineering](https://super.engineering) on NixOS. Supports x86_64 and ARM64 Linux.

## Run

With Nix and flakes enabled:

```sh
nix run github:superdoteng/nix
```

## Install

Add the app to your profile:

```sh
nix profile add github:superdoteng/nix
```

Older Nix versions use `nix profile install` instead of `nix profile add`.

For a NixOS or Home Manager configuration, add this flake input:

```nix
inputs.super-engineering.url = "github:superdoteng/nix";
```

Then include `inputs.super-engineering.packages.${pkgs.stdenv.hostPlatform.system}.default` in `environment.systemPackages` or `home.packages`, with `inputs` passed to your module.

See the [Nix installation guide](https://super.engineering/docs/nix/) for complete NixOS and Home Manager configurations, updates, and troubleshooting. The default package currently follows nightly releases.

## Update

For a profile installation, find the package name with `nix profile list`, then run:

```sh
nix profile upgrade <name>
```

For a NixOS or Home Manager configuration, update the input and rebuild:

```sh
nix flake update super-engineering
```

Your lock file keeps the selected version until you update it. Nix manages app updates; the in-app updater is disabled for Nix installations.

## About the package

The package downloads a compiled Linux release, verifies its hash, and adapts its library paths for NixOS. The desktop app remains proprietary.

Thanks to [4evy (sia / RAO)](https://github.com/4evy) for sharing and testing [native Nix packaging](https://github.com/4evy/dotfiles/blob/2f3d85d152a3895239ec5c976cd17bee3eaccd39/packages/super-engineering/package.nix).
