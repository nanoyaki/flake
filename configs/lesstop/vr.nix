{ lib, pkgs, ... }:

{
  environment.systemPackages = [
    (pkgs.writeShellScriptBin "facetracking" ''
      trap 'jobs -p | xargs kill' EXIT

      ${lib.getExe pkgs.vrcadvert} OscAvMgr 9402 9000 --tracking &

      # If using WiVRn
      ${lib.getExe pkgs.oscavmgr} openxr
    '')
  ];

  services.wivrn.package = pkgs.wivrn.overrideAttrs (prevAttrs: {
    buildInputs = prevAttrs.buildInputs ++ [
      pkgs.cudaPackages.cudatoolkit
    ];

    cmakeFlags = [
      (lib.cmakeBool "WIVRN_USE_NVENC" true)
      (lib.cmakeBool "WIVRN_USE_VAAPI" true)
      (lib.cmakeBool "WIVRN_USE_VULKAN" true)
      (lib.cmakeBool "WIVRN_USE_X264" true)
      (lib.cmakeBool "WIVRN_USE_PIPEWIRE" true)
      (lib.cmakeBool "WIVRN_USE_PULSEAUDIO" true)
      (lib.cmakeBool "WIVRN_FEATURE_STEAMVR_LIGHTHOUSE" true)
      (lib.cmakeBool "WIVRN_BUILD_CLIENT" false)
      (lib.cmakeBool "WIVRN_BUILD_DASHBOARD" true)
      (lib.cmakeBool "WIVRN_CHECK_CAPSYSNICE" false)
      (lib.cmakeBool "FETCHCONTENT_FULLY_DISCONNECTED" true)
      (lib.cmakeFeature "WIVRN_OPENXR_MANIFEST_TYPE" "absolute")
      (lib.cmakeFeature "GIT_DESC" "${prevAttrs.version}")
      (lib.cmakeFeature "FETCHCONTENT_SOURCE_DIR_MONADO" "${prevAttrs.monado}")
      (lib.cmakeFeature "CUDA_TOOLKIT_ROOT_DIR" "${pkgs.cudaPackages.cudatoolkit}")
    ];
  });
}
