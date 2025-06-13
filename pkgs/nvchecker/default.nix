{
  python3,
}:

let
  python = python3.override {
    self = python;
    packageOverrides = _: prev: {
      nvchecker = prev.nvchecker.overrideAttrs (oldAttrs: {
        patches = (oldAttrs.patches or [ ]) ++ [ ./custom-timeout.patch ];
      });
    };
  };
in
python.pkgs.nvchecker
