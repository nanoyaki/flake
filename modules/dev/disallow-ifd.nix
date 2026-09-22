# https://github.com/eveeifyeve/Nix-Config/blob/54b8fa7ce32372bbdf9a0f7857ae6860a5809592/modules/dev/disallow-ifd.nix
# https://nix.dev/manual/nix/2.35/language/import-from-derivation#:~:text=This,otherwise
{
  flake-file.nixConfig.allow-import-from-derivation = false;
}
