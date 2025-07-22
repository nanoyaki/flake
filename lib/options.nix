{ lib, lib' }:

let
  inherit (lib) types;
  inherit (lib.lists) map;
  inherit (lib'.types) singleAttrOf;
in

rec {
  mkOption = type: default: lib.mkOption { inherit type default; };
  mkDefault = default: option: mkOption option.type default;

  # Option modifiers
  mkAttrsOf = option: mkOption (types.attrsOf option.type) { };
  mkSingleAttrOf = option: mkOption (singleAttrOf option.type) { };
  mkNullOr = option: mkOption (types.nullOr option.type) null;
  mkListOf = option: mkOption (types.listOf option.type) [ ];
  mkEither = option1: option2: mkOption (types.either option1.type option2.type) option1.default;
  mkOneOf =
    options:
    mkOption (types.oneOf (map (option: option.type) options)) (builtins.elemAt options 0).default;
  mkFunctionTo = option: mkOption (types.functionTo option.type) (_: option.default);

  # Default options
  mkTrueOption = mkOption types.bool true;
  mkFalseOption = mkOption types.bool false;
  mkStrOption = mkOption types.str "";
  mkIntOption = mkOption types.int 0;
  mkPortOption = mkOption types.port 0;
  mkEnumOption = enum: mkOption (types.enum enum) (builtins.elemAt enum 0);
  mkSubmoduleOption = options: mkOption (types.submodule { inherit options; }) { };
  mkPathOption = mkOption types.path "/";
  mkAttrsOption = mkOption types.attrs { };
}
