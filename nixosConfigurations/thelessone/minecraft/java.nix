{ pkgs, ... }:

{
  environment.systemPackages = [
    (pkgs.writeShellScriptBin "java" ''${pkgs.jdk21_headless.outPath}/bin/java "$@"'')
    (pkgs.writeShellScriptBin "java21" ''${pkgs.jdk21_headless.outPath}/bin/java "$@"'')
    (pkgs.writeShellScriptBin "java17" ''${pkgs.jdk17_headless.outPath}/bin/java "$@"'')
    (pkgs.writeShellScriptBin "java8" ''${pkgs.jdk8_headless.outPath}/bin/java "$@"'')
  ];

  environment.variables.JAVA_HOME = "${pkgs.jdk21_headless}/lib/openjdk";
}
