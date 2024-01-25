{...}: let
  populateFirmwareCommands = ''
    (cd ${pkgs.raspberrypifw}/share/raspberrypi/boot && cp bootcode.bin fixup*.dat start*.elf $NIX_BUILD_TOP/firmware/)

    # Add the config
    cp ${configTxt} firmware/config.txt

    # Add pi3 specific files
    cp ${pkgs.ubootRaspberryPi3_64bit}/u-boot.bin firmware/u-boot-rpi3.bin

    # Add pi4 specific files
    cp ${pkgs.ubootRaspberryPi4_64bit}/u-boot.bin firmware/u-boot-rpi4.bin
    cp ${pkgs.raspberrypi-armstubs}/armstub8-gic.bin firmware/armstub8-gic.bin
    cp ${pkgs.raspberrypifw}/share/raspberrypi/boot/bcm2711-rpi-4-b.dtb firmware/
    cp ${pkgs.raspberrypifw}/share/raspberrypi/boot/bcm2711-rpi-400.dtb firmware/
    cp ${pkgs.raspberrypifw}/share/raspberrypi/boot/bcm2711-rpi-cm4.dtb firmware/
    cp ${pkgs.raspberrypifw}/share/raspberrypi/boot/bcm2711-rpi-cm4s.dtb firmware/
  '';
in {
  system.activationScripts = {
    stdio.text = populateFirmwareCommands;
  };
}
