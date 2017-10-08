{ stdenv, hostPlatform, pkgs, perl, buildLinux, ... } @ args:

let
  armbianPatches = map (path: {
    name = "armbian-${path}";
    patch = "${pkgs.armbian}/patch/kernel/${path}";
  }) [
    "sun50i-dev/arm64_increasing_DMA_block_memory_allocation_to_2048.patch"
    "sun50i-dev/add-h3-h5-THS.patch"
    "sun50i-dev/add-overlay-compilation-support.patch"
    "sun50i-dev/add-spi-flash-pc2.patch"
    "sun50i-dev/add-sunxi64-overlays.patch"
    "sun50i-dev/add-sy8106a-driver.patch"
    "sun50i-dev/add-ths-DT-h5.patch"
    "sun50i-dev/add_sun50i_a64_spi.patch"
    "sun50i-dev/enable-fsl-timer-errata.patch"
    "sun50i-dev/fix-i2c2-reg-property.patch"
    "sun50i-dev/scripts-dtc-import-updates.patch"
    "sun50i-dev/spidev-remove-warnings.patch"
 ];
in import <nixpkgs/pkgs/os-specific/linux/kernel/generic.nix> (args // rec {
  version = "4.13.y";
  modDirVersion = "4.13.0";
  extraMeta.branch = "4.13";

  src = pkgs.fetchFromGitHub {
    owner = "Icenowy";
    repo = "linux";
    rev = "sunxi64-${version}";
    sha256 = "0nwdl12hcj2368hlwaax555mjz0w9vj5qrwik5bwkvffbxn2xrpa";
  };

  kernelPatches = pkgs.linux_4_12.kernelPatches ++ armbianPatches ++ [
    {   name = "add-sun50i-defconfig";
        patch = ../../patches/add-sun50i-defconfig.patch; }];

  features.iwlwifi = false;
  features.efiBootStub = true;
  features.needsCifsUtils = true;
  features.netfilterRPFilter = true;
} // (args.argsOverride or {}))