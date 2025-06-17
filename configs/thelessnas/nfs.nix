{
  services.nfs.server = {
    enable = true;
    exports = ''

    '';
  };

  networking.firewall.allowedTCPPorts = [ 2049 ];
}
