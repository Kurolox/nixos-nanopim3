let
  wantedModules = ''
    USB_G_SERIAL m
    USB_GADGETFS m
    USB_FUNCTIONFS m
    USB_CDC_COMPOSITE m
    USB_DWC2 m
    BLK_DEV_NBD m
    OVERLAY_FS m
    SQUASHFS m
    NFS_FS y
    CLEANCACHE y
    FRONTSWAP y
    ZPOOL y
    Z3FOLD y
    ZSWAP y
    BCMDHD n
    CRYPTO_LZ4HC m
  '';
  excludeModules = ''
    INFINIBAND n
    DRM_NOUVEAU n
    DRM_AMDGPU n
    DRM_RADEON n
    IWLWIFI n
  '';
  armv7l-hf-multiplatform = {
    name = "armv7l-hf-multiplatform";
    kernelMajor = "2.6"; # Using "2.6" enables 2.6 kernel syscalls in glibc.
    kernelHeadersBaseConfig = "multi_v7_defconfig";
    kernelBaseConfig = "multi_v7_defconfig";
    kernelArch = "arm";
    kernelDTB = true;
    kernelAutoModules = false;
    kernelPreferBuiltin = false;
    kernelTarget = "Image";
    kernelExtraConfig = ''
      ${wantedModules}
      ${excludeModules}
    '';
    gcc = {
      # Some table about fpu flags:
      # http://community.arm.com/servlet/JiveServlet/showImage/38-1981-3827/blogentry-103749-004812900+1365712953_thumb.png
      # Cortex-A5: -mfpu=neon-fp16
      # Cortex-A7 (rpi2): -mfpu=neon-vfpv4
      # Cortex-A8 (beaglebone): -mfpu=neon
      # Cortex-A9: -mfpu=neon-fp16
      # Cortex-A15: -mfpu=neon-vfpv4

      # More about FPU:
      # https://wiki.debian.org/ArmHardFloatPort/VfpComparison

      # vfpv3-d16 is what Debian uses and seems to be the best compromise: NEON is not supported in e.g. Scaleway or Tegra 2,
      # and the above page suggests NEON is only an improvement with hand-written assembly.
      arch = "armv7-a";
      fpu = "vfpv3-d16";
      float = "hard";

      # For Raspberry Pi the 2 the best would be:
      #   cpu = "cortex-a7";
      #   fpu = "neon-vfpv4";
    };
  };

  aarch64-multiplatform = {
    name = "aarch64-multiplatform";
    kernelMajor = "2.6"; # Using "2.6" enables 2.6 kernel syscalls in glibc.
    kernelHeadersBaseConfig = "defconfig";
    kernelBaseConfig = "defconfig";
    kernelArch = "arm64";
    kernelDTB = true;
    kernelAutoModules = false;
    kernelPreferBuiltin = true;
    kernelExtraConfig = ''
      ${wantedModules}
      ${excludeModules}
    '';
    kernelTarget = "Image";
    gcc = {
      arch = "armv8-a";
    };
  };
in {
  inherit aarch64-multiplatform;
  inherit armv7l-hf-multiplatform;
  armv7l-hf-base = armv7l-hf-multiplatform // { kernelBaseConfig = "defconfig"; };
  armv7l-sunxi = armv7l-hf-multiplatform // {
    extraKernelConfig = ''
      USB_MUSB_HDRC=y
      USB_MUSB_DUAL_ROLE=y
      USB_MUSB_SUNXI=y
      MUSB_PIO_ONLY=y
      USB_PHY=y
      NOP_USB_XCEIV=y
      ${wantedModules}
      ${excludeModules}
    '';
    kernelBaseConfig = "sunxi_defconfig";
    kernelTarget = "zImage";
    gcc = {
      arch = "armv7-a";
      cpu = "cortex-a7";
      fpu = "neon-vfpv4";
      float = "hard";
    };
  };
  aarch64-sunxi = aarch64-multiplatform // {
    kernelBaseConfig = "defconfig";
  };
  aarch64-nanopi-m3 = aarch64-multiplatform // {
    kernelBaseConfig = "nanopim3_defconfig";
  };
  aarch64-x3399 = aarch64-multiplatform // {
    kernelBaseConfig = "x3399_defconfig";
  };
}
