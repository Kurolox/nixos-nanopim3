{ config, lib, pkgs, ... }:

with lib;

{
  imports = [
    ../common.nix
  ];

  assertions = lib.singleton {
    assertion = pkgs.stdenv.system == "armv7l-linux";
    message = "package can be only built natively on armhf-linux; " +
      "it cannot be cross compiled on ${pkgs.stdenv.system}";
  };

  sdImage =   let
    extlinux-conf-builder =
      import <nixpkgs/nixos/modules/system/boot/loader/generic-extlinux-compatible/extlinux-conf-builder.nix> {
        inherit pkgs;
    };
    uboot = pkgs.buildUBoot rec {
      version = "2017.07";
      src = pkgs.fetchurl {
        url = "ftp://ftp.denx.de/pub/u-boot/u-boot-${version}.tar.bz2";
        sha256 = "1zzywk0fgngm1mfnhkp8d0v57rs51zr1y6rp4p03i6nbibfbyx2k";
      };
      defconfig = "nanopi_neo_defconfig";
      targetPlatforms = [ "armv7l-linux" ];
      filesToInstall = [ "u-boot.img" "spl/sunxi-spl.bin" ];
    };
    in {
     populateBootCommands = ''
      # Write bootloaders to sd image
      dd if=${uboot}/sunxi-spl.bin conv=notrunc of=$out bs=1024 seek=8
      dd if=${uboot}/u-boot.img conv=notrunc of=$out sdX bs=1024 seek=40

      # Populate ./boot with extlinux
      ${extlinux-conf-builder} -t 3 -c ${config.system.build.toplevel} -d ./boot
    '';
  };

  boot.loader.grub.enable = false;
  boot.loader.generic-extlinux-compatible.enable = true;

  boot.kernelPackages = pkgs.linuxPackages_sunxi;
  boot.initrd.kernelModules = [ "dwc2" "g_ether" "lz4" "lz4_compress" ];
  boot.initrd.availableKernelModules = [ ];
  boot.kernelParams = ["earlyprintk" "console=ttySAC0,115200n8" "console=tty0" "brcmfmac.debug=30" "zswap.enabled=1" "zswap.compressor=lz4" "zswap.max_pool_percent=80" ];
  boot.consoleLogLevel = 7;

  nixpkgs.config = {
     allowUnfree = true;
     platform =  {
       name = "nanopi-neo";
       kernelMajor = "2.6"; # Using "2.6" enables 2.6 kernel syscalls in glibc.
       kernelHeadersBaseConfig = "multi_v7_defconfig";
       kernelBaseConfig = "multi_v7_defconfig";
       kernelArch = "arm";
       kernelDTB = true;
       kernelAutoModules = true;
       kernelPreferBuiltin = true;
       uboot = null;
       kernelTarget = "zImage";
       kernelExtraConfig = ''
         # Fix broken sunxi-sid nvmem driver.
         TI_CPTS y

         # Hangs ODROID-XU4
         ARM_BIG_LITTLE_CPUIDLE n
        '';
        gcc = {
          arch = "armv7-a";
          fpu = "vfpv3-d16";
          float = "hard";
        };
      };
   };

  networking.hostName = "nanopi-neo";

}
