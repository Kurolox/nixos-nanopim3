{ config, lib, pkgs, ... }:

let
  platforms = (import ../platforms.nix);
in {
  imports = [
    ./include/common.nix
    ./include/bluetooth.nix
    ./include/wireless.nix
  ];

  nixpkgs.config.writeBootloader = ''
    dd if=${pkgs.uboot-nanopi-air}/u-boot-sunxi-with-spl.bin conv=notrunc of=$out bs=1024 seek=8
  '';
  boot.extraTTYs = [ "ttyS0" ];
  boot.kernelPackages = pkgs.linuxPackages_testing_local;

  nixpkgs.config.platform = platforms.armv7l-hf-multiplatform;
  hardware.firmware = [ pkgs.ap6212-firmware ];

  networking.hostName = "nanopi-air";

}