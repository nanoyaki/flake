{ lib, pkgs, ... }:

let
  getJava = pkg: lib.getExe' pkg "java";
in

{
  environment.systemPackages = [
    (pkgs.writeShellScriptBin "java" ''${getJava pkgs.jdk21} "$@"'')
    (pkgs.writeShellScriptBin "java21" ''${getJava pkgs.jdk21} "$@"'')
    (pkgs.writeShellScriptBin "java17" ''${getJava pkgs.jdk17} "$@"'')
    (pkgs.writeShellScriptBin "java8" ''${getJava pkgs.openjdk8-bootstrap} "$@"'')
  ];

  environment.variables.JAVA_HOME = "${pkgs.jdk21}/lib/openjdk";
}
