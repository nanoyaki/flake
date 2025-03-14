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
            export NIX_SSHOPTS="-t -i ''${2:-$HOME/.ssh/deployment}"
            goal="''${1:-switch}"

            nixos-rebuild "$goal" --flake "${self}#thelessone" --target-host "at" --use-remote-sudo --verbose --print-build-logs
          '';
        };
      };
    };
}
