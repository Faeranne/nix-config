{
  hardware.printers = {
    ensurePrinters = [
      {
        name = "hp-colorjet";
        location = "Home";
        deviceUri = "hp:/usb/HP_Color_LaserJet_1600?serial=JV409LA";
        model = "drv:///hp/hpcups.drv/hp-color_laserjet_1600.ppd";
        ppdOptions = {
          PageSize = "Letter";
        };
      }
    ];
  };
}
