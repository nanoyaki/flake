{ config, ... }:

{
  configurations.nixos.himawari = {
    imports = [ config.modules.nixos.usbguard ];

    services.usbguard.rules = ''
      allow id 1d6b:0002 serial "0000:04:00.3" name "xHCI Host Controller" hash "6N1TzJjHwwpfxs1tKPqEW87V2i+tHyyRUvFlgF5cGtw=" parent-hash "SnsOOjjMpOpERReA2LN1+REpSYWXke1WQeUhO0X7e8g=" with-interface 09:00:00 with-connect-type ""
      allow id 1d6b:0003 serial "0000:04:00.3" name "xHCI Host Controller" hash "2Me4PXJzViXbjaI8fZWxxzrVLgY0qXCNY9Ax13jk3EE=" parent-hash "SnsOOjjMpOpERReA2LN1+REpSYWXke1WQeUhO0X7e8g=" with-interface 09:00:00 with-connect-type ""
      allow id 1d6b:0002 serial "0000:04:00.4" name "xHCI Host Controller" hash "SQO9g2Bt21p8dKkNmw9lqWKzphaGisG3dmz0QWJVjzc=" parent-hash "T5AHPbumyvtJmkwKMGdQ5v4Lin/ywbMb8JI3Pchy/l8=" with-interface 09:00:00 with-connect-type ""
      allow id 1d6b:0003 serial "0000:04:00.4" name "xHCI Host Controller" hash "UGhLGLgCW2JTjhPahEx27JNhQUqybnAzp0pRnCDj4ck=" parent-hash "T5AHPbumyvtJmkwKMGdQ5v4Lin/ywbMb8JI3Pchy/l8=" with-interface 09:00:00 with-connect-type ""
      allow id 10a5:9800 serial "" name "FPC Sensor Controller L:0002 FW:27.26.23.18" hash "+LvEKvkYg8ajdA5QJ9zdK77jUxeisGwWkyRmtT7CF/w=" parent-hash "SQO9g2Bt21p8dKkNmw9lqWKzphaGisG3dmz0QWJVjzc=" via-port "3-3" with-interface ff:ff:ff with-connect-type "hardwired"
      allow id 5986:215f serial "01.00.00" name "Integrated Camera" hash "rqaLj3eCLfkPaS/rNWdh9nM08hl1maSGVJobGG67B6U=" parent-hash "6N1TzJjHwwpfxs1tKPqEW87V2i+tHyyRUvFlgF5cGtw=" with-interface { 0e:01:01 0e:02:01 0e:02:01 0e:02:01 0e:02:01 0e:02:01 0e:02:01 0e:02:01 0e:02:01 0e:02:01 0e:02:01 0e:02:01 0e:02:01 fe:01:01 } with-connect-type "hardwired"
      allow id 0489:e0cd serial "000000000" name "Wireless_Device" hash "3JopVFWGRS5OUECbrpyI91sYwRcWP7uB1x2MwHhAtnM=" parent-hash "SQO9g2Bt21p8dKkNmw9lqWKzphaGisG3dmz0QWJVjzc=" with-interface { e0:01:01 e0:01:01 e0:01:01 e0:01:01 e0:01:01 e0:01:01 e0:01:01 e0:01:01 e0:01:01 e0:01:01 } with-connect-type "hardwired"
    '';
  };

  configurations.nixos.shirayuri = {
    imports = [ config.modules.nixos.usbguard ];

    services.usbguard.rules = ''
      allow id 1d6b:0002 serial "0000:02:00.0" name "xHCI Host Controller" hash "4+i1fOQzh6/CdbdfiwrmdTYf8TLnLkUDuN34mexLwrg=" parent-hash "VWFGb1mvEnmw1lIrXHKYSzgP8x/QIoOY2NUuEU5jiAo=" with-interface 09:00:00 with-connect-type ""
      allow id 1d6b:0003 serial "0000:02:00.0" name "xHCI Host Controller" hash "dmR8EZq+bulAtCjc2bVI0LYev+vk92bQ/cq9b3PJMtg=" parent-hash "VWFGb1mvEnmw1lIrXHKYSzgP8x/QIoOY2NUuEU5jiAo=" with-interface 09:00:00 with-connect-type ""
      allow id 1d6b:0002 serial "0000:0a:00.3" name "xHCI Host Controller" hash "iUjxIR1pxa22oauStMQh5E0Es3LFCV8t6/IjTiahEnY=" parent-hash "zl6qlbQWWE7mu2U8JXfAPFR8aCqQC6Qy9lHeqzxK+eU=" with-interface 09:00:00 with-connect-type ""
      allow id 1d6b:0003 serial "0000:0a:00.3" name "xHCI Host Controller" hash "bkxdZLrNLi1jzuDnauFUdZ2IF0xtgDUoqr03AnGNBK4=" parent-hash "zl6qlbQWWE7mu2U8JXfAPFR8aCqQC6Qy9lHeqzxK+eU=" with-interface 09:00:00 with-connect-type ""
      allow id 048d:5702 serial "" name "ITE Device" hash "xzYUEylvVhtgbdYpTWru+9ogFZh7W8JE4xhHuvKVl2w=" parent-hash "4+i1fOQzh6/CdbdfiwrmdTYf8TLnLkUDuN34mexLwrg=" via-port "1-3" with-interface 03:00:00 with-connect-type "hotplug"
      allow id 2109:2817 serial "" name "USB2.0 Hub" hash "4Z0RGjcL3PS7i6mfTRV0Vl4UXFSOvtN0OJoB/E5mOtY=" parent-hash "iUjxIR1pxa22oauStMQh5E0Es3LFCV8t6/IjTiahEnY=" via-port "3-2" with-interface { 09:00:01 09:00:02 } with-connect-type "hotplug"
      allow id 2109:0817 serial "" name "USB3.0 Hub" hash "/raLfe7XIcjy9ngslAMX2LEhKMjKHLIDxSqNWhtsG4k=" parent-hash "bkxdZLrNLi1jzuDnauFUdZ2IF0xtgDUoqr03AnGNBK4=" via-port "4-2" with-interface 09:00:00 with-connect-type "hotplug"
    '';
  };

  modules.nixos.usbguard = {
    services.usbguard = {
      enable = true;
      dbus.enable = true;
      implicitPolicyTarget = "block";
      rules = ''
        allow id 349e:0024 serial "" name "FIDO2 Security Key(0024)" with-interface { 03:00:00 0b:00:00 } with-connect-type "hotplug"
        allow id 1235:8211 serial "Y78PR8A1C2ADDA" name "Scarlett Solo USB" with-interface { 01:01:20 01:02:20 01:02:20 01:02:20 01:02:20 ff:01:20 } with-connect-type "hotplug"
        allow id 2516:008d serial "" name "SK650" with-interface { 03:01:01 03:00:00 03:00:00 } with-connect-type "hotplug"
        allow id 1038:12ad serial "" name "SteelSeries Arctis 7" with-interface { 01:01:00 01:02:00 01:02:00 01:02:00 01:02:00 01:01:00 01:02:00 01:02:00 01:02:00 03:00:00 } with-connect-type "hotplug"
      ''
      # Logitech mouse
      + ''
        allow id 046d:c547 serial "" name "USB Receiver" with-interface { 03:01:02 03:01:01 03:00:00 }
      '';
    };
  };

  modules.nixos.setup =
    { lib, pkgs, ... }:

    let
      inherit (lib) mkForce;
    in

    {
      environment.systemPackages = [ pkgs.usbguard ];
      services.usbguard.enable = mkForce false;
    };
}
