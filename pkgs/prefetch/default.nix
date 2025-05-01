{
  writeShellApplication,
  nix,
}:

writeShellApplication {
  name = "prefetch";
  runtimeInputs = [ nix ];
  text = ''
    nix hash convert --hash-algo sha256 --to sri "$(nix-prefetch-url "$@")"
  '';

  meta.description = "Simple shell script to make getting hashes for files easier";
}
