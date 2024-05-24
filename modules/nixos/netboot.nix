# Note that when building the raspberry pi based netboot system
# we use hostId to determine the netboot directory, since that
# also matchs the serial number rpi4 uses for netbooting.
{inputs, config, systemConfig, lib, pkgs, ...}: let
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
    kernel=kernel
    initramfs initrd followkernel
    enable_gic=1
    armstub=armstub8-gic.bin

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
    avoid_warnings=1

  '';
  # This can be used to rebuild the target with the needed specialArgs for the host
  extendTarget = target: host: target.extendModules {
    specialArgs = {
      hostServer = host;
    };
    # netboot-target has details that can never be used on a standard host.
    # so we only include it here.
    modules = [
      ./netboot-target.nix
    ];
  };
  netbootLines = lib.strings.concatMapStrings (serv: let
    targetConfig = netbootConfigs.${serv};
    target = extendTarget inputs.self.nixosConfigurations.${serv} {ip = systemConfig.ip;};
    hostId = targetConfig.hostId;
    topLevel = target.config.system.build.toplevel;
    commandlineTxt = pkgs.writeText "commandline.txt" ''
      init=${target.config.system.build.toplevel}/init ${toString target.config.boot.kernelParams} 
    '';
  in ''
      mkdir -p $out/${hostId}/{boot,dtbs}
      cp -r ${target.pkgs.raspberrypifw}/share/raspberrypi/boot/{overlays/,bootcode.bin,fixu*.dat,star*.elf,*.dtb} $out/${netbootConfigs.${serv}.hostId}/.
      ln -s ${target.config.system.build.toplevel}/kernel $out/${hostId}/kernel
      ln -s ${target.config.system.build.toplevel}/initrd $out/${hostId}/initrd
      ln -s ${configTxt} $out/${hostId}/config.txt
      ln -s ${commandlineTxt} $out/${hostId}/cmdline.txt
      ln -s ${target.pkgs.raspberrypi-armstubs}/armstub8-gic.bin $out/${hostId}/armstub8-gic.bin
    ''
  ) netbootHosts; 
  netbootImages = pkgs.runCommand "netboot" {} ''
    mkdir $out
    ${netbootLines}
  '';
in {
  services = {
    nfs.server.exports = ''
      /nix/store 192.168.1.0/24(insecure,ro,sync,no_subtree_check,all_squash)
    '';
    atftpd = lib.mkIf isNetbootServer {
      enable = true;
      root = netbootImages;
    };
  };
  networking.firewall = lib.mkIf isNetbootServer {
    allowedTCPPorts = [ 69 ];
    allowedUDPPorts = [ 69 6665 ];
  };
}
