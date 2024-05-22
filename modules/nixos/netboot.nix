# Note that when building the raspberry pi based netboot system
# we use hostId to determine the netboot directory, since that
# also matchs the serial number rpi4 uses for netbooting.
{inputs, systemConfig, lib, pkgs, ...}: let
  utils = import ../../lib/utils;
  netbootConfigs = utils.getNetbootConfigs;
  netbootHosts = builtins.attrNames netbootConfigs;
  isNetbootServer = (builtins.elem "netboot-server" systemConfig.elements);
  configTxt = pkgs.writeText "config.txt" ''
    [pi3]
    kernel=u-boot-rpi3.bin

    [pi02]
    kernel=u-boot-rpi3.bin

    [pi4]
    #kernel=u-boot-rpi4.bin
    kernel=kernel.img
    initramfs initrd.img followkernel
    #enable_gic=1
    #armstub=armstub8-gic.bin

    # Otherwise the resolution will be weird in most cases, compared to
    # what the pi3 firmware does by default.
    disable_overscan=1

    # Supported in newer board revisions
    arm_boost=1

    [cm4]
    # Enable host mode on the 2711 built-in XHCI USB controller.
    # This line should be removed if the legacy DWC2 controller is required
    # (e.g. for USB device mode) or if USB support is not required.
    otg_mode=1

    [all]
    # Boot in 64-bit mode.
    arm_64bit=1

    # U-Boot needs this to work, regardless of whether UART is actually used or not.
    # Look in arch/arm/mach-bcm283x/Kconfig in the U-Boot tree to see if this is still
    # a requirement in the future.
    enable_uart=1

    # Prevent the firmware from smashing the framebuffer setup done by the mainline kernel
    # when attempting to show low-voltage or overtemperature warnings.
    #avoid_warnings=1

  '';
  netbootLines = lib.strings.concatMapStrings (serv: let
    targetConfig = netbootConfigs.${serv};
    target = inputs.self.nixosConfigurations.${serv};
    hostId = targetConfig.hostId;
    topLevel = target.config.system.build.toplevel;
    boot = pkgs.runCommand "bootFile" {} ''
      mkdir -p $out
      ${target.config.boot.loader.generic-extlinux-compatible.populateCmd} -c ${target.config.system.build.toplevel} -d $out
    '';
    initram = target.config.system.build.initialRamdisk;
    kernel = target.config.system.build.kernel;
    commandlineTxt = pkgs.writeText "commandline.txt" ''
      init=${target.config.system.build.toplevel}/init ${toString target.config.boot.kernelParams}
    '';
    linuxCfg = ''
      DEFAULT menu.c32
      PROMPT 0
      TIMEOUT 100
      ONTIMEOUT nixos

      LABEL nixos
        MENU LABEL NixOS: ${hostId}
        LINUX ${hostId}/kernel.img
        INITRD ${hostId}/initrd.img
        APPEND init=${topLevel}/init boot.shell_on_fail console=ttyS0,115200n8 console=ttyAMA0,115200n8 console=tty0 nohibernate loglevel=7
        FDTDIR ${hostId}/dtbs
    '';
  in ''
      mkdir -p $out/${hostId}/{boot,dtbs}
      cp -r ${inputs.self.nixosConfigurations.${serv}.pkgs.raspberrypifw}/share/raspberrypi/boot/{overlays/,bootcode.bin,fixu*.dat,star*.elf,*.dtb} $out/${netbootConfigs.${serv}.hostId}/.
      cp ${boot}/nixos/*initrd* $out/${hostId}/initrd
      cp -r ${boot}/nixos/* $out/${hostId}/boot
      cp -r ${kernel}/dtbs/* $out/${hostId}/dtbs
      ln -s ${topLevel} $out/${hostId}/root
      ln -s ${kernel}/${target.config.system.boot.loader.kernelFile} $out/${hostId}/kernel.img
      ln -s ${initram}/initrd.zst $out/${hostId}/initrd.img
      ln -s ${configTxt} $out/${hostId}/config.txt
      ln -s ${commandlineTxt} $out/${hostId}/cmdline.txt
      ln -s ${target.pkgs.raspberrypi-armstubs}/armstub8-gic.bin $out/${hostId}/armstub8-gic.bin
      ln -s ${target.pkgs.ubootNet}/u-boot.bin $out/${hostId}/u-boot-rpi4.bin
      echo "${linuxCfg}" > $out/pxelinux.cfg/${targetConfig.netboot.mac}
    ''
  ) netbootHosts; 
  netbootImages = pkgs.stdenv.mkDerivation {
    name = "netbootImages";
    src = pkgs.fetchurl {
      url = "https://mirrors.edge.kernel.org/pub/linux/utils/boot/syslinux/syslinux-6.03.tar.gz";
      hash = "sha256-JQub2QlF02FZanpplD0L3F/AwJF6pWJgn40wWKLDazo=";
  #netbootImages = pkgs.runCommand "netboot" {} ''
    };
    buildCommand = ''
      mkdir $out
      mkdir -p $out/{pxelinux.cfg,dtb}
      ${netbootLines}
      tar -xzf $src
      cp -r syslinux-6.03/bios/com32/chain/chain.c32 $out/
      cp -r syslinux-6.03/bios/com32/mboot/mboot.c32 $out/
      cp -r syslinux-6.03/bios/memdisk/memdisk $out/
      cp -r syslinux-6.03/bios/com32/menu/menu.c32 $out/
      cp -r syslinux-6.03/bios/core/pxelinux.0 $out/
    '';
  };
in {
  services = {
    nfs.server.exports = ''
      /nix 192.168.1.0/24(insecure,ro,sync,no_subtree_check,all_squash)
    '';
    atftpd = lib.mkIf isNetbootServer {
      enable = true;
      root = netbootImages;
    };
    syslogd = {
      tty = "";
      enable = true;
      enableNetworkInput = true;
    };
  };
  networking.firewall = lib.mkIf isNetbootServer {
    allowedTCPPorts = [ 69 ];
    allowedUDPPorts = [ 69 6665 ];
  };
}
