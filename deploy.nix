{ self, ... }:

{
  perSystem =
    { pkgs, ... }:
    {
      apps.deploy = {
        type = "app";
        program = pkgs.writeShellApplication {
          name = "deploy";
          runtimeInputs = [ pkgs.nixos-rebuild ];

          text = ''
            goal="''${1:-switch}"
            export NIX_SSHOPTS="-t -i ''${2:-$HOME/.ssh/deployment}"
            target="''${3:-thelessone@theless.one}"

            nixos-rebuild "$goal" --flake "${self}#thelessone" --target-host "$target" --use-remote-sudo --print-build-logs
          '';
        };
      };
    };
}
