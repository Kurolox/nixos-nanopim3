{ supportedSystems ? [ "aarch64-linux" ] }:

let
  pkgs = import <nixpkgs> { };
  lib = pkgs.lib;
  versionModule =
    { system.nixosVersionSuffix = "embedded";
      system.nixosRevision = "git";
    };
  makeSdImage =
    { module, type, system }:

    with import <nixpkgs> { inherit system; };

    lib.hydraJob ((import <nixpkgs/nixos/lib/eval-config.nix> {
      inherit system;
      modules = [ module versionModule { } ];
    }).config.system.build.sdImage );

in rec {

  odroid-c2-minimal = makeSdImage {
    module = ./boards/odroid-c2/hardware-config.nix;
    type = "minimal";
    system = "aarch64-linux";
  };
  nanopi-m3-minimal = makeSdImage {
    module = ./boards/nanopi-m3/hardware-config.nix;
    type = "minimal";
    system = "aarch64-linux";
  };
}
