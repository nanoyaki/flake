{
  lib,
  buildPythonApplication,
  fetchFromGitHub,
}:

buildPythonApplication rec {
  name = "x3d-undervolt";
  version = "0.1";

  src = fetchFromGitHub {
    repo = "Ryzen-5800x3d-linux-undervolting";
    owner = "svenlange2";
    rev = "0f05965f9939259c27a428065fda5a6c0cbb9225";
    sha256 = lib.fakeHash;
  };

  postInstall = ''
    mkdir -p $out/bin
    cp $src/ruv.py $out/bin/${name}
    chmod +x $out/bin/${name}
  '';

  meta = {
    description = "A Python script to use Ryzen SMU for Linux PBO tuning of Ryzen 5800x3d CPU. Mostly needed for Ryzen 5800x3d undervolting.";
    longDescription = ''
      A Python script to use Ryzen SMU for Linux PBO tuning of Ryzen 5800x3d CPU. Mostly needed for Ryzen 5800x3d undervolting.

      This is a linux implementation of the PBO2 undevolting tool used to undervolt Ryzen CPUs in Windows. 
      More info on how to do it in Windows is here: https://github.com/PrimeO7/How-to-undervolt-AMD-RYZEN-5800X3D-Guide-with-PBO2-Tuner
    '';
    homepage = "https://github.com/svenlange2/Ryzen-5800x3d-linux-undervolting";
    changelog = "https://github.com/svenlange2/Ryzen-5800x3d-linux-undervolting/commits/main/";
    license = lib.licenses.unfree;
    platforms = lib.platforms.linux;
  };
}
