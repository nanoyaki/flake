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

            nixos-rebuild "$goal" --flake "${self}#thelessone" --target-host "thelessone@theless.one" --use-remote-sudo --print-build-logs
          '';
        };
      };
    };
}
