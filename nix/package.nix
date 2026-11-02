# The signed super.engineering Linux release tarball, patched for Nix; nothing is built from
# source. Community reference: 4evy’s native autoPatchelf packaging:
# https://github.com/4evy/dotfiles/blob/2f3d85d152a3895239ec5c976cd17bee3eaccd39/packages/super-engineering/package.nix
# `release` is one channel's verified pin in nix/sources.json.
{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
  makeWrapper,
  fontconfig,
  freetype,
  git,
  libxcb,
  libxkbcommon,
  openssl,
  vulkan-loader,
  wayland,
  xdg-utils,
  zenity,
  channel,
  release,
}:

let
  system = stdenv.hostPlatform.system;
  artifact =
    release.${system} or (throw "super-engineering: the ${channel} release has no ${system} tarball");
  # The runtime libraries, excluding what the NixOS desktop session provides
  # itself (Vulkan drivers, xdg-desktop-portal). Some are loaded with dlopen, so they also go on
  # the binaries' RUNPATH (runtimeDependencies). Never LD_LIBRARY_PATH: every terminal and agent
  # the app starts would inherit it.
  libraries = [
    fontconfig
    freetype
    libxcb
    libxkbcommon
    openssl
    vulkan-loader
    wayland
  ];
in
stdenv.mkDerivation {
  pname = "super-engineering";
  version = if channel == "nightly" then "0-nightly-${lib.substring 0 8 artifact.commit}" else artifact.version;

  src = fetchurl { inherit (artifact) url hash; };

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
  ];
  buildInputs = [ stdenv.cc.cc.lib ] ++ libraries;
  runtimeDependencies = libraries;

  dontConfigure = true;
  dontBuild = true;

  # bin/ keeps the remote CLIs (sc-linux-*) beside the app, which looks for them next to its
  # executable.
  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp -r bin share $out/
    substituteInPlace $out/share/applications/engineering.super.app.desktop \
      --replace-fail "Exec=super-engineering" "Exec=$out/bin/super-engineering"
    runHook postInstall
  '';

  # Appended, so the user's own tools win: file dialogs (zenity), opening links (xdg-open), git.
  # The executable stays under /nix/store, which disables the in-app updater.
  postFixup = ''
    wrapProgram $out/bin/super-engineering --suffix PATH : ${
      lib.makeBinPath [
        git
        xdg-utils
        zenity
      ]
    }
  '';

  meta = {
    description = "Native workspace for parallel coding agents (${channel})";
    homepage = "https://super.engineering";
    license = lib.licenses.unfree;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    mainProgram = "super-engineering";
  };
}
