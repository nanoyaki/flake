{ config, ... }:

{
  configurations.nixos.himawari = {
    imports = [ config.modules.nixos.usbguard ];
  };

  modules.nixos.usbguard = {
    services.usbguard = {
      enable = true;
      dbus.enable = true;
      implicitPolicyTarget = "reject";
      rules = ''
        allow id 1d6b:0002 serial "0000:04:00.3" name "xHCI Host Controller" hash "6N1TzJjHwwpfxs1tKPqEW87V2i+tHyyRUvFlgF5cGtw=" parent-hash "SnsOOjjMpOpERReA2LN1+REpSYWXke1WQeUhO0X7e8g=" with-interface 09:00:00 with-connect-type ""
        allow id 1d6b:0003 serial "0000:04:00.3" name "xHCI Host Controller" hash "2Me4PXJzViXbjaI8fZWxxzrVLgY0qXCNY9Ax13jk3EE=" parent-hash "SnsOOjjMpOpERReA2LN1+REpSYWXke1WQeUhO0X7e8g=" with-interface 09:00:00 with-connect-type ""
        allow id 1d6b:0002 serial "0000:04:00.4" name "xHCI Host Controller" hash "SQO9g2Bt21p8dKkNmw9lqWKzphaGisG3dmz0QWJVjzc=" parent-hash "T5AHPbumyvtJmkwKMGdQ5v4Lin/ywbMb8JI3Pchy/l8=" with-interface 09:00:00 with-connect-type ""
        allow id 1d6b:0003 serial "0000:04:00.4" name "xHCI Host Controller" hash "UGhLGLgCW2JTjhPahEx27JNhQUqybnAzp0pRnCDj4ck=" parent-hash "T5AHPbumyvtJmkwKMGdQ5v4Lin/ywbMb8JI3Pchy/l8=" with-interface 09:00:00 with-connect-type ""
        allow id 10a5:9800 serial "" name "FPC Sensor Controller L:0002 FW:27.26.23.18" hash "+LvEKvkYg8ajdA5QJ9zdK77jUxeisGwWkyRmtT7CF/w=" parent-hash "SQO9g2Bt21p8dKkNmw9lqWKzphaGisG3dmz0QWJVjzc=" via-port "3-3" with-interface ff:ff:ff with-connect-type "hardwired"
        allow id 5986:215f serial "01.00.00" name "Integrated Camera" hash "rqaLj3eCLfkPaS/rNWdh9nM08hl1maSGVJobGG67B6U=" parent-hash "6N1TzJjHwwpfxs1tKPqEW87V2i+tHyyRUvFlgF5cGtw=" with-interface { 0e:01:01 0e:02:01 0e:02:01 0e:02:01 0e:02:01 0e:02:01 0e:02:01 0e:02:01 0e:02:01 0e:02:01 0e:02:01 0e:02:01 0e:02:01 fe:01:01 } with-connect-type "hardwired"
        allow id 0489:e0cd serial "000000000" name "Wireless_Device" hash "3JopVFWGRS5OUECbrpyI91sYwRcWP7uB1x2MwHhAtnM=" parent-hash "SQO9g2Bt21p8dKkNmw9lqWKzphaGisG3dmz0QWJVjzc=" with-interface { e0:01:01 e0:01:01 e0:01:01 e0:01:01 e0:01:01 e0:01:01 e0:01:01 e0:01:01 e0:01:01 e0:01:01 } with-connect-type "hardwired"
        allow id 349e:0024 serial "" name "FIDO2 Security Key(0024)" with-interface { 03:00:00 0b:00:00 } with-connect-type "hotplug"
      '';
    };
  };
}
